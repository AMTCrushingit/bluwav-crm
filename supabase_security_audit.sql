-- ================================================================
-- BluWav CRM — Supabase Security Audit SQL
-- Run each section in Supabase SQL Editor
-- ================================================================

-- ── SECTION 1: Check RLS status on all tables ──────────────────
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled,
  CASE WHEN rowsecurity THEN '✅ RLS ON' ELSE '❌ RLS OFF — CRITICAL' END as status
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- ── SECTION 2: List all RLS policies ──────────────────────────
SELECT 
  tablename,
  policyname,
  cmd as operation,
  roles,
  qual as using_expression,
  with_check
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, cmd;

-- ── SECTION 3: Check for tables with RLS ON but NO policies ────
-- (RLS on + no policies = nobody can access = silent data loss)
SELECT t.tablename,
  '⚠️ RLS enabled but NO policies — all queries will return empty' as warning
FROM pg_tables t
WHERE t.schemaname = 'public' 
  AND t.rowsecurity = true
  AND NOT EXISTS (
    SELECT 1 FROM pg_policies p 
    WHERE p.schemaname = 'public' AND p.tablename = t.tablename
  );

-- ── SECTION 4: Verify auth.users linkage ──────────────────────
-- Check profiles table has correct user references
SELECT 
  COUNT(*) as total_profiles,
  COUNT(CASE WHEN id IS NULL THEN 1 END) as null_ids,
  COUNT(CASE WHEN role IS NULL THEN 1 END) as null_roles,
  COUNT(CASE WHEN full_name IS NULL THEN 1 END) as null_names
FROM profiles;

-- ── SECTION 5: Check for orphaned records ─────────────────────
-- Contacts without a valid user
SELECT COUNT(*) as orphaned_contacts
FROM contacts c
WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = c.user_id);

-- Deals without a valid agent
SELECT COUNT(*) as orphaned_deals  
FROM deals d
WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = d.agent_id);

-- ── SECTION 6: Storage bucket audit ──────────────────────────
SELECT 
  id as bucket_name,
  public,
  CASE WHEN public THEN '⚠️ Public bucket' ELSE '✅ Private bucket' END as visibility,
  created_at
FROM storage.buckets;

-- ── SECTION 7: Storage RLS policies ──────────────────────────
SELECT 
  name as policy_name,
  bucket_id,
  operation,
  definition
FROM storage.policies
ORDER BY bucket_id;

-- ── SECTION 8: Check for overly permissive policies ───────────
-- Flag any policy that allows ALL users (including anon) to write
SELECT tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public'
  AND cmd IN ('INSERT', 'UPDATE', 'DELETE')
  AND (roles @> ARRAY['anon']::name[] OR roles = ARRAY['public']::name[])
ORDER BY tablename;

-- ── SECTION 9: Recommended RLS policies if missing ────────────
-- Run these if Section 1 shows any table with RLS OFF

-- contacts: users see own, managers see all
-- ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "contacts_select" ON contacts FOR SELECT
--   USING (auth.uid() = user_id OR 
--          (SELECT role FROM profiles WHERE id = auth.uid()) IN ('manager','admin','owner'));
-- CREATE POLICY "contacts_insert" ON contacts FOR INSERT
--   WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "contacts_update" ON contacts FOR UPDATE
--   USING (auth.uid() = user_id OR 
--          (SELECT role FROM profiles WHERE id = auth.uid()) IN ('manager','admin','owner'));

-- deals: agents see own, managers see all
-- ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "deals_select" ON deals FOR SELECT
--   USING (auth.uid() = agent_id OR 
--          (SELECT role FROM profiles WHERE id = auth.uid()) IN ('manager','admin','owner'));

-- tasks: users see own only
-- ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "tasks_select" ON tasks FOR SELECT USING (auth.uid() = user_id);
-- CREATE POLICY "tasks_insert" ON tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "tasks_update" ON tasks FOR UPDATE USING (auth.uid() = user_id);
-- CREATE POLICY "tasks_delete" ON tasks FOR DELETE USING (auth.uid() = user_id);

-- activities: users see own, managers see all
-- ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "activities_select" ON activities FOR SELECT
--   USING (auth.uid() = user_id OR 
--          (SELECT role FROM profiles WHERE id = auth.uid()) IN ('manager','admin','owner'));
-- CREATE POLICY "activities_insert" ON activities FOR INSERT WITH CHECK (auth.uid() = user_id);

-- profiles: users see own, managers see all
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "profiles_select" ON profiles FOR SELECT
--   USING (auth.uid() = id OR 
--          (SELECT role FROM profiles WHERE id = auth.uid()) IN ('manager','admin','owner'));
-- CREATE POLICY "profiles_update" ON profiles FOR UPDATE
--   USING (auth.uid() = id)
--   WITH CHECK (auth.uid() = id AND role = (SELECT role FROM profiles WHERE id = auth.uid()));

-- corex_leads: super admin only
-- ALTER TABLE corex_leads ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "corex_leads_superadmin" ON corex_leads
--   USING ((SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin','owner'));

-- ── SECTION 10: Auth configuration check ─────────────────────
-- Check email confirmation settings (run in Supabase dashboard)
-- Authentication → Settings → confirm:
-- ✅ Email confirmations: ON (for production)
-- ✅ Secure email change: ON  
-- ✅ Password minimum length: 8+
-- ✅ MFA: Enabled on your admin account
-- ✅ JWT expiry: 3600 (1 hour) or less
