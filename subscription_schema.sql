-- ============================================================
-- BluWav CRM — Subscription Status Schema
-- Run in Supabase SQL Editor
-- ============================================================

-- Add subscription columns to profiles table
ALTER TABLE profiles 
  ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'trial',
  ADD COLUMN IF NOT EXISTS subscription_lapsed_at TIMESTAMPTZ DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS plan TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS plan_activated_at TIMESTAMPTZ DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS onboarding_complete BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS onboarding_completed_at TIMESTAMPTZ DEFAULT NULL;

-- subscription_status values:
--   'trial'    = 14-day free trial (default)
--   'active'   = paying subscriber
--   'lapsed'   = payment stopped (grace period starts)
--   'readonly' = grace period expired (data visible, not editable)
--   'cancelled' = account cancelled

-- Index for fast status queries
CREATE INDEX IF NOT EXISTS idx_profiles_subscription_status 
  ON profiles(subscription_status);

-- Verify
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'profiles'
AND column_name IN ('subscription_status','subscription_lapsed_at','plan','plan_activated_at','onboarding_complete')
ORDER BY column_name;
