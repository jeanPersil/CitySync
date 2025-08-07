from supabase import create_client, Client

supabase_url = "https://hqyyltlpltrxvikkncjf.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxeXlsdGxwbHRyeHZpa2tuY2pmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MDkzODcsImV4cCI6MjA3MDA4NTM4N30.cFFTNe6MwbXpu9H5hMM0KovKoNHlV0cxWMfWLNsvh0k"

from flask_mysqldb import MySQL

mysql = MySQL()

def init_supabase():  
    return create_client(supabase_url, supabase_key)