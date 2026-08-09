-- ============================================================
-- BluWav CRM — profiles RLS hardening
-- Run this in Supabase SQL Editor
-- Prevents users from escalating their own role
-- ============================================================

-- First, check existing policies
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'profiles';

-- Drop any existing UPDATE policy on profiles that lacks role protection
-- (Replace 'existing_policy_name' with actual name from above query)
-- DROP POLICY IF EXISTS "existing_policy_name" ON profiles;

-- Create hardened UPDATE policy
-- Users can update their own profile BUT cannot change their role
-- Only admins/owners can change roles
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "profiles_update_policy" ON profiles;

CREATE POLICY "Users update own profile no role change" ON profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (
    -- Allow update only if role is unchanged OR user is admin/owner
    role = (SELECT role FROM profiles WHERE id = auth.uid())
    OR
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'owner')
  );

-- Verify
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'profiles';
