-- Run this in Supabase SQL Editor to add source_code column to contacts
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS source_code TEXT;

-- Also add deal_value if missing (used by COREX sync)
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS deal_value NUMERIC DEFAULT 0;

-- Refresh schema cache (Supabase does this automatically, but just in case)
NOTIFY pgrst, 'reload schema';
