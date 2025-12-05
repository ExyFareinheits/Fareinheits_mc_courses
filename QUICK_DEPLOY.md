# 🚀 Quick Deploy to Vercel

## Step 1: Prepare Environment
```bash
# Make sure all dependencies installed
npm install

# Test local build
npm run build
npm run preview
```

## Step 2: Push to GitHub
```bash
git add .
git commit -m "feat: production ready - redesigned UI, filled free courses, mobile responsive"
git push origin main
```

## Step 3: Deploy on Vercel

### Via Web Dashboard (Easiest)
1. Go to https://vercel.com
2. Click "Add New" → "Project"
3. Import from GitHub repository
4. Configure:
   - **Framework Preset**: Vite
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
5. Add Environment Variables:
   ```
   VITE_SUPABASE_URL=https://okzqwsngcohadkecoyrh.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9renF3c25nY29oYWRrZWNveXJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NTQ2MDMsImV4cCI6MjA4MDAzMDYwM30.cWebQ1k_JfFCC8NTby4AVIHb2IjMyxHRrKF6ew0g2IU
   ```
6. Click "Deploy"

### Via CLI (Alternative)
```bash
# Install Vercel CLI globally
npm i -g vercel

# Login
vercel login

# Deploy to production
vercel --prod
```

## Step 4: Post-Deployment Checklist

### Test Website
- [ ] Homepage loads
- [ ] All 10 courses display
- [ ] Free/Paid filter works
- [ ] Course details open
- [ ] Mobile responsive (test on phone)
- [ ] No console errors (F12)

### Supabase Check
- [ ] RLS policies active (`supabase/rls_course_tables.sql` executed)
- [ ] Free-1 lessons display (execute `free1_server_basics/FREE1_ALL_LESSONS.sql`)
- [ ] User authentication works
- [ ] Course access requests work

### Performance
- [ ] Lighthouse score 90+ (mobile)
- [ ] First Contentful Paint < 2s
- [ ] No 404 errors in Network tab

## Step 5: Custom Domain (Optional)

1. Go to Project → Settings → Domains
2. Add domain: `mc-courses.com`
3. Configure DNS at your registrar:
   ```
   Type: CNAME
   Name: @
   Value: cname.vercel-dns.com
   ```
4. Wait for DNS propagation (5-60 minutes)

## 🐛 Troubleshooting

### Build Fails
```bash
# Clear cache and rebuild
rm -rf node_modules dist
npm install
npm run build
```

### Environment Variables Not Working
- Redeploy project in Vercel dashboard
- Check variable names exactly match: `VITE_SUPABASE_URL`
- No quotes needed in Vercel UI

### Supabase Connection Error
```sql
-- Re-execute RLS policies in Supabase SQL Editor
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read" ON course_modules FOR SELECT USING (true);
```

### Mobile Layout Broken
- Check browser console for errors
- Test responsive in Chrome DevTools (F12 → Toggle device toolbar)
- Verify Tailwind classes: `sm:`, `md:`, `lg:` breakpoints

## 📱 Mobile Test URLs

Test on real devices:
- Android: Chrome browser
- iOS: Safari browser

Test responsive:
- Chrome DevTools (F12) → Responsive mode
- Firefox Responsive Design Mode (Ctrl+Shift+M)
- Edge DevTools

## 🎉 Success!

Your site is now live at: `https://your-project.vercel.app`

Next steps:
1. Share with community for feedback
2. Monitor Vercel Analytics
3. Add more course content
4. Integrate payment system (optional)

---

**Questions?** Check `DEPLOYMENT.md` for detailed guide.
