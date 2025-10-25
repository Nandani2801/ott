# db_manager.py

import mysql.connector

# =================================================================
# !! IMPORTANT: UPDATE THESE WITH YOUR MYSQL CREDENTIALS !!
# =================================================================
DB_CONFIG = {
    'user': 'root',
    'password': 'nandani@2024',
    'host': 'localhost',
    'database': 'ott',
}

def execute_procedure(procedure_name, args=()):
    """
    Connects to the DB, executes a stored procedure, and returns results.
    """
    conn = None
    cursor = None
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        # Use buffered=True and dictionary=True for flexibility in fetching results
        cursor = conn.cursor(buffered=True, dictionary=True) 
        
        # Construct the CALL statement dynamically
        call_statement = f"CALL {procedure_name}({', '.join(['%s'] * len(args))})"
        cursor.execute(call_statement, args)
        
        # Commit changes for procedures that modify data
        conn.commit()
        
        # Stored procedures can return multiple result sets. We fetch all.
        results_list = []
        for result in cursor.stored_results():
            # If the procedure returns data (like sp_user_watch_summary)
            results_list.extend(result.fetchall()) 
        
        # Return the first result set, or an empty list if none
        return results_list if results_list else {'status': 'success'}

    except mysql.connector.Error as err:
        print(f"Error executing procedure {procedure_name}: {err}")
        return {'status': 'error', 'message': str(err)}
        
    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()

# Example function for direct SELECT queries (for fetching lists)
def execute_query(query, args=None):
    conn = None
    cursor = None
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, args or ())
        results = cursor.fetchall()
        return results
    except mysql.connector.Error as err:
        print(f"Error executing query: {err}")
        return {'status': 'error', 'message': str(err)}
    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()