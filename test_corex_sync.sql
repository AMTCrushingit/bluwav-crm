-- Run this in Supabase SQL Editor to fix COREX → CRM sync
-- Step 1: Add missing columns
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS source_code TEXT;
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS deal_value NUMERIC DEFAULT 0;

-- Step 2: Verify columns exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'contacts' 
AND column_name IN ('source_code', 'deal_value', 'full_name', 'email', 'status', 'user_id')
ORDER BY column_name;

-- Step 3: Check existing contacts from COREX (source_code = 'IH')
SELECT id, full_name, email, business_name, source_code, status, created_at
FROM contacts 
WHERE source_code = 'IH'
ORDER BY created_at DESC
LIMIT 10;
