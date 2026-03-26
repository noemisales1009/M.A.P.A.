import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://cjqgogtqzmrfxgdfnnos.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqcWdvZ3Rxem1yZnhnZGZubm9zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MTk5ODIsImV4cCI6MjA4ODI5NTk4Mn0.hKf72xRTYdknzdJeSICV7VRZ30t6jLbSwHCUmgzpqqs';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
