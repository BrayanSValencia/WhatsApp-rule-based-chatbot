import mysql.connector
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database configuration
DB_CONFIG = {
    'host': os.getenv("DB_HOST"),
    'user': os.getenv("DB_USER"),
    'password': os.getenv("DB_PASSWORD"),
    'database': os.getenv("DB_NAME"),
}

# Initialize user sessions
user_sessions = {}

# Session timeout duration (15 minutes)
SESSION_TIMEOUT = timedelta(minutes=15)

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

def process_message(message, sender):
    # Normalize message and sender
    message = message.lower().strip()
    sender = sender.strip()

    # Clean up inactive sessions
    clean_inactive_sessions()

    # Initialize session if not exists
    if sender not in user_sessions:
        user_sessions[sender] = {
            'state': 'verify_id',
            'data': {},
            'last_activity': datetime.now()
        }
    else:
        # Update last activity time
        user_sessions[sender]['last_activity'] = datetime.now()

    current_session = user_sessions[sender]
    response = ""

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # State machine implementation
        if current_session['state'] == 'verify_id':
            response = handle_verify_id(message, cursor, current_session, conn)

        elif current_session['state'] == 'main_menu':
            response = handle_main_menu(message, cursor, current_session, conn)

        elif current_session['state'] == 'select_specialty':
            response = handle_select_specialty(message, cursor, current_session, conn)

        elif current_session['state'] == 'select_doctor':
            response = handle_select_doctor(message, cursor, current_session, conn)

        elif current_session['state'] == 'select_date':
            response = handle_select_date(message, cursor, current_session, conn)

        elif current_session['state'] == 'select_time':
            response = handle_select_time(message, cursor, current_session, sender, conn)

        elif current_session['state'] == 'cancel_appointment':
            response = handle_cancel_appointment(message, cursor, current_session, sender, conn)

        # Handle common commands in any state
        if any(cmd in message for cmd in ['menú', 'volver', 'inicio']):
            current_session['state'] = 'main_menu'
            response = get_main_menu_response(current_session)

        elif 'ayuda' in message:
            response = get_help_response()

        elif 'emergencia' in message:
            response = "🚨 Para emergencias, por favor llame directamente al 123."

        elif any(phrase in message for phrase in ['gracias', 'agradecido', 'agradecida']):
            response = "De nada! Estoy aquí para ayudarle. ¿Necesita algo más?"

        elif any(cmd in message for cmd in ['reiniciar', 'nuevo usuario', 'otro usuario', 'salir']):
            if sender in user_sessions:
                del user_sessions[sender]
            return "¡Listo! Hemos terminado por ahora. Si necesitas agendar otra cita, estaré aquí para ayudarte.🙂"

        # Close database connection
        cursor.close()
        conn.close()

        return response if response else "No entendí su mensaje. Por favor intente nuevamente."

    except Exception as e:
        print(f"Error: {e}")
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()
        return "❌ Ocurrió un error. Por favor intente nuevamente más tarde."

def clean_inactive_sessions():
    """Remove sessions that have been inactive for longer than SESSION_TIMEOUT."""
    current_time = datetime.now()
    inactive_senders = [
        sender for sender, session in user_sessions.items()
        if current_time - session['last_activity'] > SESSION_TIMEOUT
    ]
    for sender in inactive_senders:
        del user_sessions[sender]
        print(f"Session for {sender} timed out and was removed.")

# Rest of your functions remain unchanged
def handle_main_menu(message, cursor, current_session, conn):
    if '1' in message or 'agendar' in message:
        current_session['state'] = 'select_specialty'
        cursor.execute("SELECT DISTINCT id, name FROM Specialty")
        specialties = cursor.fetchall()
        specialties_text = "\n".join(f"{i}. {spec['name']}" for i, spec in enumerate(specialties, start=1))
        current_session['data']['specialties'] = specialties
        return f"Seleccione especialidad:\n{specialties_text}\n\nEscriba 'atrás' para volver"

    elif '2' in message or 'cancelar' in message:
        current_session['state'] = 'cancel_appointment'
        return get_user_appointments(cursor, current_session)

    elif '3' in message or 'ver' in message:
        return show_user_appointments(cursor, current_session)

    else:
        return get_main_menu_response(current_session)

def handle_verify_id(message, cursor, current_session, conn):
    if message.isdigit() and 8 <= len(message) <= 10:
        cursor.execute("""
            SELECT u.id, u.dni, CONCAT(u.first_name, ' ', u.last_name) AS full_name
            FROM User u
            JOIN DocumentType dt ON u.document_type_id = dt.id
            WHERE u.dni = %s AND u.is_active = 1
        """, (message,))
        patient = cursor.fetchone()
        if patient:
            current_session['state'] = 'main_menu'
            current_session['data']['patient'] = patient
            return get_main_menu_response(current_session)
        else:
            return ("🔍 No encontramos tu número de identificación en nuestro sistema. "
                    "Por favor verifica el número o regístrate en nuestra clínica.\n\n"
                    "🔹 Escribe 'reiniciar' para intentar con otro número\n"
                    "🔹 Escribe 'salir' para terminar")
    else:
        return ("Por favor ingresa tu número de identificación (solo números, entre 8 y 10 dígitos):\n\n"
                "🔹 Escribe 'salir' para terminar")

def get_main_menu_response(current_session):
    patient_name = current_session['data']['patient']['full_name']
    return (f"👋 Hola {patient_name}, ¿en qué podemos ayudarte hoy?\n\n"
            "1. 📅 Agendar una nueva cita\n"
            "2. ❌ Cancelar una cita existente\n"
            "3. 👁️ Ver mis citas programadas\n\n"
            "🔹 Selecciona una opción (1, 2 o 3)\n"
            "🔹 Escribe 'ayuda' para ver más opciones\n"
            "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
            "🔹 Escribe 'salir' para terminar")

def handle_select_specialty(message, cursor, current_session, conn):
    if 'atrás' in message:
        current_session['state'] = 'main_menu'
        return get_main_menu_response(current_session)

    specialties = current_session['data']['specialties']

    try:
        selection = int(message)
        if 1 <= selection <= len(specialties):
            current_session['state'] = 'select_doctor'
            selected_specialty = specialties[selection-1]
            cursor.execute("""
                SELECT d.id, d.dni, CONCAT(d.first_name, ' ', d.last_name) AS full_name
                FROM Doctor d
                WHERE d.specialty_id = %s AND d.is_active = 1
            """, (selected_specialty['id'],))
            doctors = cursor.fetchall()
            current_session['data']['doctors'] = doctors
            current_session['data']['selected_specialty'] = selected_specialty
            doctors_text = "\n".join(f"{i}. Dr. {doc['full_name']}" for i, doc in enumerate(doctors, start=1))
            return (f"👨‍⚕️ Médicos disponibles en {selected_specialty['name']}:\n{doctors_text}\n\n"
                    "🔹 Selecciona el número del médico que prefieras\n"
                    "🔹 Escribe 'atrás' para elegir otra especialidad\n"
                    "🔹 Escribe 'menú' para volver al inicio\n"
                    "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                    "🔹 Escribe 'salir' para terminar")
    except ValueError:
        pass
    return ("❌ Opción no válida. Por favor selecciona un número de la lista.\n\n"
            "🔹 Escribe 'atrás' para regresar\n"
            "🔹 Escribe 'menú' para volver al inicio\n"
            "🔹 Escribe 'reiniciar' para atender a otro usuario")

def handle_select_doctor(message, cursor, current_session, conn):
    if 'atrás' in message.lower():
        current_session['state'] = 'select_specialty'
        specialties = current_session['data']['specialties']
        specialties_text = "\n".join(f"{i}. {spec['name']}" for i, spec in enumerate(specialties, start=1))
        return f"📋 Especialidades disponibles:\n{specialties_text}"

    doctors = current_session['data']['doctors']

    try:
        selection = int(message)
        if 1 <= selection <= len(doctors):
            current_session['state'] = 'select_date'
            selected_doctor = doctors[selection-1]
            current_session['data']['doctor'] = selected_doctor

            now = datetime.now()

            cursor.execute("""
                SELECT DISTINCT DATE(da.time_slot) as線
                FROM DoctorAgenda da
                WHERE da.doctor_id = %s
                  AND da.appointment_state_id = (SELECT id FROM appointmentstate WHERE state = 'Free')
                  AND da.time_slot >= %s
                ORDER BY DATE(da.time_slot)
            """, (selected_doctor['id'], now))

            rows = cursor.fetchall()
            if not rows:
                return (f"ℹ️ Actualmente el Dr. {selected_doctor['full_name']} no tiene fechas disponibles.\n\n"
                        "🔹 Escribe 'atrás' para elegir otro médico\n"
                        "🔹 Escribe 'menú' para volver al inicio\n"
                        "🔹 Escribe 'reiniciar' para atender a otro usuario")

            available_dates = [row['date'] for row in rows]
            current_session['data']['available_dates'] = available_dates

            dates_text = "\n".join(
                f"{i}. {date.strftime('%A %d de %B %Y')}" for i, date in enumerate(available_dates, start=1)
            )

            return (f"📅 Fechas disponibles con el Dr. {selected_doctor['full_name']}:\n{dates_text}\n\n"
                    "🔹 Selecciona el número de la fecha que prefieras\n"
                    "🔹 Escribe 'atrás' para elegir otro médico\n"
                    "🔹 Escribe 'menú' para volver al inicio\n"
                    "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                    "🔹 Escribe 'salir' para terminar")
    except ValueError:
        pass

    return ("❌ Opción no válida. Por favor selecciona un número de la lista.\n\n"
            "🔹 Escribe 'atrás' para regresar\n"
            "🔹 Escribe 'menú' para volver al inicio\n"
            "🔹 Escribe 'reiniciar' para atender a otro usuario")

def handle_select_date(message, cursor, current_session, conn):
    if 'atrás' in message.lower():
        current_session['state'] = 'select_doctor'
        doctors = current_session['data']['doctors']
        doctors_text = "\n".join(f"{i}. Dr. {doc['full_name']}" for i, doc in enumerate(doctors, start=1))
        return f"👨‍⚕️ Médicos disponibles:\n{doctors_text}"

    dates = current_session['data']['available_dates']
    try:
        selection = int(message)
        if 1 <= selection <= len(dates):
            current_session['state'] = 'select_time'
            selected_date = dates[selection-1]
            current_session['data']['selected_date'] = selected_date

            doctor_id = current_session['data']['doctor']['id']

            cursor.execute("""
                SELECT da.id, da.time_slot
                FROM DoctorAgenda da
                WHERE da.doctor_id = %s
                  AND DATE(da.time_slot) = %s
                  AND da.appointment_state_id = (SELECT id FROM appointmentstate WHERE state = 'Free')
                ORDER BY da.time_slot
            """, (doctor_id, selected_date))

            slots = cursor.fetchall()
            if not slots:
                return ("ℹ️ No hay horarios disponibles para la fecha seleccionada.\n\n"
                        "🔹 Escribe 'atrás' para elegir otra fecha\n"
                        "🔹 Escribe 'menú' para volver al inicio\n"
                        "🔹 Escribe 'reiniciar' para atender a otro usuario")

            current_session['data']['available_slots'] = slots

            times_text = "\n".join(
                f"{i}. {slot['time_slot'].strftime('%I:%M %p')}" for i, slot in enumerate(slots, start=1)
            )

            return (f"⏰ Horarios disponibles para el {selected_date.strftime('%A %d de %B')}:\n{times_text}\n\n"
                    "🔹 Selecciona el número del horario que prefieras\n"
                    "🔹 Escribe 'atrás' para elegir otra fecha\n"
                    "🔹 Escribe 'menú' para volver al inicio\n"
                    "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                    "🔹 Escribe 'salir' para terminar")
    except ValueError:
        pass

    return ("❌ Opción no válida. Por favor selecciona un número de la lista.\n\n"
            "🔹 Escribe 'atrás' para regresar\n"
            "🔹 Escribe 'menú' para volver al inicio\n"
            "🔹 Escribe 'reiniciar' para atender a otro usuario")

def handle_select_time(message, cursor, current_session, sender, conn):
    if 'atrás' in message.lower():
        current_session['state'] = 'select_date'
        dates = current_session['data']['available_dates']
        dates_text = "\n".join(f"{i}. {date.strftime('%A %d de %B %Y')}" for i, date in enumerate(dates, start=1))
        return f"📅 Fechas disponibles:\n{dates_text}"

    slots = current_session['data']['available_slots']
    try:
        selection = int(message)
        if 1 <= selection <= len(slots):
            selected_slot = slots[selection-1]
            current_session['data']['selected_slot_id'] = selected_slot['id']
            return book_appointment(cursor, current_session, sender, selected_slot['time_slot'], conn)
    except ValueError:
        pass

    return ("❌ Opción no válida. Por favor selecciona un horario de la lista.\n\n"
            "🔹 Escribe 'atrás' para regresar\n"
            "🔹 Escribe 'menú' para volver al inicio\n"
            "🔹 Escribe 'reiniciar' para atender a otro usuario")

def book_appointment(cursor, current_session, sender, selected_time, conn):
    try:
        cursor.execute("""
            INSERT INTO UserAppointments (
                user_id,
                doctor_agenda_id,
                booked_datetime
            ) VALUES (
                %s,
                %s,
                NOW()
            )
        """, (current_session['data']['patient']['id'], current_session['data']['selected_slot_id']))

        cursor.execute("""
            UPDATE DoctorAgenda
            SET appointment_state_id = (SELECT id FROM appointmentstate WHERE state = 'Scheduled')
            WHERE id = %s
        """, (current_session['data']['selected_slot_id'],))

        conn.commit()

        user_sessions[sender] = {'state': 'main_menu', 'data': current_session['data'], 'last_activity': datetime.now()}
        return (f"✅ ¡Cita agendada con éxito!\n\n"
                f"👨‍⚕️ Médico: Dr. {current_session['data']['doctor']['full_name']}\n"
                f"📅 Fecha: {current_session['data']['selected_date'].strftime('%A %d de %B %Y')}\n"
                f"⏰ Hora: {selected_time.strftime('%I:%M %p')}\n\n"
                "Recibirás un recordatorio un día antes de tu cita.\n\n"
                "🔹 Escribe 'menú' para volver al inicio\n"
                "🔹 Escribe 'mis citas' para ver tus citas programadas\n"
                "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                "🔹 Escribe 'salir' para terminar")
    except Exception as e:
        print(f"Error booking appointment: {e}")
        conn.rollback()
        return ("❌ Lo sentimos, no pudimos agendar tu cita. Por favor intenta nuevamente.\n\n"
                "🔹 Escribe 'menú' para volver al inicio\n"
                "🔹 Escribe 'reiniciar' para comenzar de nuevo\n"
                "🔹 Escribe 'salir' para terminar")

def handle_cancel_appointment(message, cursor, current_session, sender, conn):
    try:
        if 'atrás' in message.lower():
            current_session['state'] = 'main_menu'
            return get_main_menu_response(current_session)

        if 'appointments' not in current_session['data']:
            return get_user_appointments(cursor, current_session)

        appointments = current_session['data']['appointments']
        if not appointments:
            return ("ℹ️ Actualmente no tienes citas programadas que puedas cancelar.\n\n"
                    "🔹 Escribe 'menú' para volver al inicio\n"
                    "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                    "🔹 Escribe 'salir' para terminar")

        try:
            selection = int(message)
            if 1 <= selection <= len(appointments):
                appointment = appointments[selection - 1]

                cursor.execute("""
                    SELECT da.id, da.time_slot
                    FROM DoctorAgenda da
                    JOIN UserAppointments ua ON da.id = ua.doctor_agenda_id
                    WHERE ua.user_id = %s AND DATE(da.time_slot) = %s
                """, (current_session['data']['patient']['id'], appointment['time_slot'].date()))

                agenda_info = cursor.fetchone()
                if not agenda_info:
                    return ("❌ No pudimos encontrar la cita seleccionada en nuestro sistema.\n\n"
                            "🔹 Escribe 'menú' para volver al inicio\n"
                            "🔹 Escribe 'reiniciar' para comenzar de nuevo\n"
                            "🔹 Escribe 'salir' para terminar")

                cursor.execute("SELECT id FROM AppointmentState WHERE state = 'Free'")
                free_id = cursor.fetchone()['id']

                cursor.execute("""
                    DELETE FROM UserAppointments
                    WHERE user_id = %s AND doctor_agenda_id = %s
                """, (current_session['data']['patient']['id'], agenda_info['id']))

                cursor.execute("""
                    UPDATE DoctorAgenda
                    SET appointment_state_id = %s
                    WHERE id = %s
                """, (free_id, agenda_info['id']))

                conn.commit()

                current_session['state'] = 'main_menu'
                current_session['data'].pop('appointments', None)
                user_sessions[sender] = {
                    'state': 'main_menu',
                    'data': current_session['data'],
                    'last_activity': datetime.now()
                }

                return ("✅ Tu cita ha sido cancelada exitosamente. Recibirás una confirmación por correo electrónico.\n\n"
                        "🔹 Escribe 'menú' para volver al inicio\n"
                        "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                        "🔹 Escribe 'salir' para terminar")
            else:
                return ("❌ El número ingresado no corresponde a ninguna cita.\n\n"
                        "🔹 Por favor ingresa un número válido de la lista\n"
                        "🔹 Escribe 'atrás' para regresar\n"
                        "🔹 Escribe 'menú' para volver al inicio\n"
                        "🔹 Escribe 'reiniciar' para atender a otro usuario")
        except ValueError:
            return ("❌ Por favor ingresa solo el número de la cita que deseas cancelar.\n\n"
                    "🔹 Escribe 'atrás' para regresar\n"
                    "🔹 Escribe 'menú' para volver al inicio\n"
                    "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                    "🔹 Escribe 'salir' para terminar")

    except Exception as e:
        print(f"Error canceling appointment: {e}")
        if conn.is_connected():
            conn.rollback()
        return ("❌ Lo sentimos, no pudimos cancelar tu cita en este momento.\n\n"
                "🔹 Por favor intenta nuevamente más tarde\n"
                "🔹 Escribe 'menú' para volver al inicio\n"
                "🔹 Escribe 'reiniciar' para comenzar de nuevo\n"
                "🔹 Escribe 'salir' para terminar")

def get_user_appointments(cursor, current_session):
    cursor.execute("""
        SELECT 
            d.first_name,
            d.last_name,
            s.name AS specialty,
            ua.booked_datetime AS booked_time,
            da.time_slot AS time_slot
        FROM userappointments ua
        JOIN doctoragenda da ON ua.doctor_agenda_id = da.id
        JOIN doctor d ON da.doctor_id = d.id
        JOIN specialty s ON d.specialty_id = s.id
        JOIN `user` u ON ua.user_id = u.id AND u.id = %s
        ORDER BY da.time_slot
    """, (current_session['data']['patient']['id'],))

    appointments = cursor.fetchall()

    if not appointments:
        return ("ℹ️ No tienes citas programadas actualmente.\n\n"
                "🔹 Escribe 'menú' para volver al inicio\n"
                "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                "🔹 Escribe 'salir' para terminar")

    current_session['data']['appointments'] = appointments

    appointments_text = "\n".join(
        f"{i}. 👨‍⚕️ **Dr. {app['first_name']} {app['last_name']}**\n"
        f"   🏥 Especialidad: {app['specialty']}\n"
        f"   📅 Fecha: {app['booked_time'].strftime('%A %d de %B %Y')}\n"
        f"   ⏰ Hora: {app['time_slot'].strftime('%I:%M %p')}\n"
        for i, app in enumerate(appointments, start=1))

    return (f"📋 **Tus citas programadas:**\n\n{appointments_text}\n\n"
            "🔹 Ingresa el **número** de la cita que deseas cancelar\n"
            "🔹 Escribe 'atrás' para regresar\n"
            "🔹 Escribe 'menú' para volver al inicio\n"
            "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
            "🔹 Escribe 'salir' para terminar")

def show_user_appointments(cursor, current_session):
    cursor.execute("""
        SELECT 
            d.first_name,
            d.last_name,
            s.name AS specialty,
            ua.booked_datetime AS booked_time,
            da.time_slot AS time_slot
        FROM userappointments ua
        JOIN doctoragenda da ON ua.doctor_agenda_id = da.id
        JOIN doctor d ON da.doctor_id = d.id
        JOIN specialty s ON d.specialty_id = s.id
        JOIN `user` u ON ua.user_id = u.id AND u.id = %s
        ORDER BY da.time_slot
    """, (current_session['data']['patient']['id'],))

    appointments = cursor.fetchall()

    if not appointments:
        return ("ℹ️ No tienes citas programadas actualmente.\n\n"
                "🔹 Escribe 'menú' para volver al inicio\n"
                "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
                "🔹 Escribe 'salir' para terminar")

    appointments_text = "\n".join(
        f"• 👨‍⚕️ **Dr. {app['first_name']} {app['last_name']}**\n"
        f"  🏥 Especialidad: {app['specialty']}\n"
        f"  📅 Fecha: {app['booked_time'].strftime('%A %d de %B %Y')}\n"
        f"  ⏰ Hora: {app['time_slot'].strftime('%I:%M %p')}\n"
        for app in appointments)

    return (f"📋 **Tus próximas citas:**\n\n{appointments_text}\n\n"
            "🔹 Escribe 'cancelar' si deseas cancelar alguna cita\n"
            "🔹 Escribe 'menú' para volver al inicio\n"
            "🔹 Escribe 'reiniciar' para atender a otro usuario\n"
            "🔹 Escribe 'salir' para terminar")

def get_help_response():
    return ("ℹ️ **Centro de Ayuda**\n\n"
            "Puedo asistirte con:\n"
            "• 📅 **Agendar citas**: Escribe 'agendar' o selecciona la opción 1\n"
            "• ❌ **Cancelar citas**: Escribe 'cancelar' o selecciona la opción 2\n"
            "• 👁️ **Ver tus citas**: Escribe 'mis citas' o selecciona la opción 3\n\n"
            "**Comandos de navegación**:\n"
            "• 'menú' - Volver al inicio principal\n"
            "• 'atrás' - Regresar al paso anterior\n"
            "• 'reiniciar' - Comenzar con un nuevo usuario\n"
            "• 'salir' - Terminar la conversación\n"
            "• 'ayuda' - Mostrar este mensaje\n\n"
            "🚨 **Para emergencias médicas** llama al 911.")