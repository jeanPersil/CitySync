const { createClient } = require("@supabase/supabase-js");

const supabaseUrl = "https://hqyyltlpltrxvikkncjf.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxeXlsdGxwbHRyeHZpa2tuY2pmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MDkzODcsImV4cCI6MjA3MDA4NTM4N30.cFFTNe6MwbXpu9H5hMM0KovKoNHlV0cxWMfWLNsvh0k";

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
