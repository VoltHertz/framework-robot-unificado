import pyodbc
import sys
import os
import time

AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID = os.environ.get("AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID", "")
AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET = os.environ.get("AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET", "")


def get_connection_string():
    connection_string_sql_authentication = (
        "Driver={ODBC Driver 17 for SQL Server};"
        "Server=tcp:azr-sdbs-pf-td-nova-transacional-dev-n.database.windows.net,1433;"
        "Database=azr-sdb-pf-td-nova-transacional-dev-n;"
        f"UID={AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID};"
        f"PWD={AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET};"
        "Authentication=ActiveDirectoryServicePrincipal;"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=180;"
        "Login Timeout=180;"
    )
    return connection_string_sql_authentication


def connect_to_database():
    """Conecta ao banco de dados usando as credenciais do Service Principal."""
    if not AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID or not AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID.strip():
        raise Exception("❌ AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID não está definido ou está vazio")
    if not AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET or not AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET.strip():
        raise Exception("❌ AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET não está definido ou está vazio")

    print(f"🔐 Conectando com Service Principal: {AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID}")
    conn_string = get_connection_string()
    print("📋 Connection string (mascarada): Driver={ODBC Driver 17 for SQL Server};Server=...;Database=...;UID=***;PWD=***;Authentication=ActiveDirectoryServicePrincipal;...")
    start_time = time.time()
    try:
        conn = pyodbc.connect(conn_string)
        elapsed_time = time.time() - start_time
        print(f"✅ Conexão estabelecida com sucesso em {elapsed_time:.2f} segundos")
        return conn
    except pyodbc.Error as e:
        elapsed_time = time.time() - start_time
        print(f"❌ Erro de conexão ODBC após {elapsed_time:.2f} segundos: {e}")
        raise


if __name__ == "__main__":
    try:
        drivers = pyodbc.drivers()
        sql_drivers = [driver for driver in drivers if 'SQL Server' in driver]
        if not sql_drivers:
            print("❌ Nenhum driver SQL Server encontrado!")
            sys.exit(1)
        conn = connect_to_database()
        cur = conn.cursor()
        cur.execute("SELECT 1")
        cur.fetchone()
        cur.close()
        conn.close()
        print("✅ Conexão fechada com sucesso!")
    except Exception as e:
        print(f"❌ Erro: {e}")
        sys.exit(1)

