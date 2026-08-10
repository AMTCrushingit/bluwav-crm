# BluWav CRM — Beta Tester Guide
## End-to-End Workflow Test

**Access:** https://www.bluwavcrm.com
**Access Code:** BW2026 (or BLUWAV or BWCRM26)

---

## WORKFLOW 1: Agent Onboarding (15 mins)
1. Go to https://www.bluwavcrm.com/login.html
2. Enter access code → click Continue
3. Click "Sign up" → fill in your details → create account
4. You'll land on the dashboard — note your 14-day trial countdown
5. Navigate to **Onboarding** in the left sidebar
6. Complete all 5 onboarding steps:
   - Step 1: Watch product overview
   - Step 2: Review commission structure
   - Step 3: Read & agree to partner agreement
   - Step 4: Complete training modules
   - Step 5: Submit your profile
7. ✅ Expected: "Onboarding complete" message appears

**What to test:**
- [ ] All steps navigate correctly
- [ ] Agreement checkbox required before proceeding
- [ ] Completion message shows on step 5
- [ ] Profile saved (check Settings page)

---

## WORKFLOW 2: Lead to Deal Pipeline (20 mins)
1. From dashboard, click **+ Add Contact**
2. Fill in: First Name, Last Name, Email, Phone (select country code)
3. Click **Save Contact**
4. ✅ Expected: Contact count increases, contact appears in list

5. Click **+ New Deal**
6. Select the contact you just created from dropdown
7. Fill in: Deal Name, Value ($), Stage (Lead), Package Type
8. Click **Save Deal**
9. ✅ Expected: Deal appears in Sales Pipeline under "Lead"

10. Click the deal card → Edit → change Stage to **Qualified**
11. Save → deal moves to Qualified column
12. Repeat: Qualified → Proposal → Won
13. ✅ Expected: "Deal Won! 🎉" toast notification on Won

**What to test:**
- [ ] Contact saves and count updates
- [ ] Deal dropdown shows your contact
- [ ] Deal moves through all pipeline stages
- [ ] Won notification appears
- [ ] Commission calculator shows earnings after Won deal

---

## WORKFLOW 3: Daily Activities (10 mins)
1. Click **Tasks** in sidebar → **+ New Task**
2. Add task: "Follow up with [contact name]", set due date
3. ✅ Expected: Task appears in task list and calendar

4. Click **Calendar** → click **+ New Event**
5. Add event: "Demo call", select today's date, time 2:00 PM
6. ✅ Expected: Event appears on calendar grid

7. Click **Email** → **+ Compose Email**
8. Send test email to your own address
9. ✅ Expected: Email client opens OR success toast

**What to test:**
- [ ] Task saves and appears in list
- [ ] Calendar shows current month
- [ ] New Event opens event modal (not task modal)
- [ ] Email compose works

---

## WORKFLOW 4: Commission & Payout (10 mins)
1. Navigate to **Commission Calc** in sidebar
2. Select package type and quantity
3. ✅ Expected: Commission amount calculates correctly

4. Click **Request Payout** tab
5. Fill in payout details
6. Click **Submit Payout Request**
7. ✅ Expected: Success message, request saved

**What to test:**
- [ ] Commission calculates at 20% (standard) or 25% (3+ clients)
- [ ] Payout request submits without error
- [ ] Cannot submit duplicate pending request

---

## WORKFLOW 5: Settings & Profile (5 mins)
1. Click **Settings** in sidebar
2. Update your name → click **Save Changes**
3. ✅ Expected: Name updates in sidebar and top bar

4. Try uploading a profile photo (click avatar)
5. ✅ Expected: Photo preview appears

6. Click **Sign Out**
7. ✅ Expected: Returns to login page, gate shows again

**What to test:**
- [ ] Name saves and updates everywhere
- [ ] Photo upload works
- [ ] Sign out returns to gate screen

---

## WORKFLOW 6: Billing & Trial (5 mins)
1. Click **Billing** in sidebar
2. Note your trial countdown (should match days since signup)
3. Click **Start Free Trial** on any plan
4. ✅ Expected: Payment modal opens

5. Use test card: **4242 4242 4242 4242**, any future date, any CVC
6. ✅ Expected: Plan activates, "Free Trial" badge disappears

**What to test:**
- [ ] Trial countdown shows correct days remaining
- [ ] Payment modal opens
- [ ] Plan activates after payment
- [ ] Free Trial badge disappears after activation

---

## BUGS TO REPORT
Please note:
- What you were doing
- What you expected to happen
- What actually happened
- Screenshot if possible

Send to: hello@bluwavgrowth.com

---

*BluWav CRM Beta — Confidential Testing*
*Access Code: BW2026 | Trial: 14 days*
