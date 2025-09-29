import pyodbc
#import msal
import sys
import os
import time

AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID = os.environ.get("AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID","")
AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET = os.environ.get("AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET","")

def get_connection_string():
    # Somente testes locais
    # connection_string_interactive_authentication = (
    #     "Driver={ODBC Driver 17 for SQL Server};"
    #     "Server=tcp:azr-sdbs-pf-td-nova-transacional-dev-n.database.windows.net,1433;"
    #     "Database=azr-sdb-pf-td-nova-transacional-dev-n;"
    #     "UID=p-brucandido@bvmf.com.br;"
    #     "Authentication=ActiveDirectoryInteractive;"
    #     "Encrypt=yes;"
    #     "TrustServerCertificate=no;"
    #     "Connection Timeout=30;"
    # )
    # return connection_string_interactive_authentication

    # Testes pipeline com timeout aumentado significativamente
    connection_string_sql_authentication = (
        "Driver={ODBC Driver 17 for SQL Server};"
        "Server=tcp:azr-sdbs-pf-td-nova-transacional-dev-n.database.windows.net,1433;"
        "Database=azr-sdb-pf-td-nova-transacional-dev-n;"
        f"UID={AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID};"
        f"PWD={AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET};"
        "Authentication=ActiveDirectoryServicePrincipal;"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
        "Connection Timeout=180;"  # Aumentado para 3 minutos
        "Login Timeout=180;"       # Aumentado para 3 minutos
    )

    return connection_string_sql_authentication

def connect_to_database():
    """
    Conecta ao banco de dados usando as credenciais do Service Principal
    """
    # Verificar se as credenciais estão definidas
    if not AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID or not AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID.strip():
        raise Exception("❌ AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID não está definido ou está vazio")
    
    if not AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET or not AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET.strip():
        raise Exception("❌ AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET não está definido ou está vazio")
    
    print(f"🔐 Conectando com Service Principal: {AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID}")
    
    conn_string = get_connection_string()
    print(f"📋 Connection string (mascarada): Driver={{ODBC Driver 17 for SQL Server}};Server=...;Database=...;UID={AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID};PWD=***;Authentication=ActiveDirectoryServicePrincipal;...")
    
    # Iniciar cronômetro
    start_time = time.time()
    print(f"⏱️ Iniciando tentativa de conexão em {time.strftime('%H:%M:%S', time.localtime(start_time))}")
    
    try:
        conn = pyodbc.connect(conn_string)
        elapsed_time = time.time() - start_time
        print(f"✅ Conexão estabelecida com sucesso em {elapsed_time:.2f} segundos")
        return conn
    except pyodbc.Error as e:
        elapsed_time = time.time() - start_time
        print(f"❌ Erro de conexão ODBC após {elapsed_time:.2f} segundos: {e}")
        print(f"🔍 Código do erro: {e.args[0] if e.args else 'Sem código'}")
        if hasattr(e, 'args') and len(e.args) > 1:
            print(f"🔍 Descrição do erro: {e.args[1]}")
        raise
    except Exception as e:
        elapsed_time = time.time() - start_time
        print(f"❌ Erro inesperado na conexão após {elapsed_time:.2f} segundos: {e}")
        raise

if __name__ == "__main__":
    try:
        print("🔍 Verificando drivers ODBC disponíveis...")
        drivers = pyodbc.drivers()
        sql_drivers = [driver for driver in drivers if 'SQL Server' in driver]
        
        if sql_drivers:
            for driver in sql_drivers:
                print(f"✅ Driver encontrado: {driver}")
        else:
            print("❌ Nenhum driver SQL Server encontrado!")
            sys.exit(1)
        
        print("\n🔐 Verificando credenciais...")
        print(f"Client ID: {'✅ Definido' if AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID else '❌ Não definido'}")
        print(f"Client Secret: {'✅ Definido' if AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET else '❌ Não definido'}")
        
        print("\n🌐 Testando conectividade específica do Azure...")
        import socket
        
        # Teste de conectividade TCP direta
        print("🔌 Testando conexão TCP direta...")
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(10)
            result = sock.connect_ex(('azr-sdbs-pf-td-nova-transacional-dev-n.database.windows.net', 1433))
            sock.close()
            if result == 0:
                print("✅ Conexão TCP na porta 1433: OK")
            else:
                print("❌ Conexão TCP na porta 1433: FALHOU")
        except Exception as e:
            print(f"❌ Erro no teste TCP: {e}")
        
        # Teste de resolução DNS
        print("🔍 Testando resolução DNS...")
        try:
            ip = socket.gethostbyname('azr-sdbs-pf-td-nova-transacional-dev-n.database.windows.net')
            print(f"✅ DNS resolvido para: {ip}")
        except Exception as e:
            print(f"❌ Erro de DNS: {e}")
        
        print("\n🌐 Tentando conexão com timeout estendido (3 minutos)...")
        conn = connect_to_database()
        print("✅ Conexão bem-sucedida!")
        
        # Teste básico de conectividade
        cursor = conn.cursor()
        cursor.execute("SELECT 1 as test")
        result = cursor.fetchone()
        print(f"✅ Teste de query executado com sucesso: {result[0]}")
        
        cursor.close()
        conn.close()
        print("✅ Conexão fechada com sucesso!")
        
    except Exception as e:
        print(f"❌ Erro: {e}")
        sys.exit(1)