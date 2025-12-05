# Fareinheits MC Courses - Deployment Guide

## 🚀 Vercel Deployment

### Prerequisites
- Vercel account
- Supabase project with configured database
- GitHub repository (recommended)

### Environment Variables

Add these to Vercel dashboard (Settings → Environment Variables):

```env
VITE_SUPABASE_URL=https://okzqwsngcohadkecoyrh.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9renF3c25nY29oYWRrZWNveXJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NTQ2MDMsImV4cCI6MjA4MDAzMDYwM30.cWebQ1k_JfFCC8NTby4AVIHb2IjMyxHRrKF6ew0g2IU
```

### Deploy Steps

#### Option 1: Via Vercel CLI
```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Deploy to production
vercel --prod
```

#### Option 2: Via GitHub Integration (Recommended)
1. Push code to GitHub repository
2. Go to [vercel.com](https://vercel.com)
3. Click "Import Project"
4. Select your GitHub repository
5. Vercel auto-detects Vite config
6. Add environment variables
7. Click "Deploy"

### Build Configuration

Vercel auto-detects these from `package.json`:
- **Build Command**: `npm run build`
- **Output Directory**: `dist`
- **Install Command**: `npm install`

### Domain Configuration

After deployment:
1. Go to Project Settings → Domains
2. Add custom domain (e.g., `mc-courses.com`)
3. Configure DNS:
   - **Type**: `CNAME`
   - **Name**: `@` (or `www`)
   - **Value**: `cname.vercel-dns.com`

### Post-Deployment Checklist

- [ ] Verify environment variables are set
- [ ] Test all pages load correctly
- [ ] Check Supabase RLS policies are active
- [ ] Test course access authentication
- [ ] Verify mobile responsiveness
- [ ] Test payment integrations (if enabled)
- [ ] Check Console for errors (F12)
- [ ] Test course enrollment flow
- [ ] Verify admin panel access

## 🗄️ Supabase Setup

### Required Tables
1. `course_modules` - Course module metadata
2. `course_lessons` - Lesson content
3. `user_course_access` - User enrollment tracking
4. `course_access_requests` - Access requests
5. `admins` - Admin users
6. `admin_logs` - Admin action logs

### RLS Policies

Execute `supabase/rls_course_tables.sql`:
```sql
-- Enable RLS
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_lessons ENABLE ROW LEVEL SECURITY;

-- Public read access
CREATE POLICY "Public read access to course_modules" 
  ON course_modules FOR SELECT TO public USING (true);

CREATE POLICY "Public read access to course_lessons" 
  ON course_lessons FOR SELECT TO public USING (true);
```

### Execute SQL Files
1. Go to Supabase SQL Editor
2. Execute in order:
   - `supabase/rls_course_tables.sql` (RLS policies)
   - `free1_server_basics/FREE1_ALL_LESSONS.sql` (Free course content)
   - `free2_plugins/free2_module1_quiz1.sql` (if created)

## 📱 Mobile Optimization

### Responsive Breakpoints
- **xs**: `480px` (extra small phones)
- **sm**: `640px` (phones)
- **md**: `768px` (tablets)
- **lg**: `1024px` (laptops)
- **xl**: `1280px` (desktops)

### Mobile-First Features
- Touch-friendly buttons (48px minimum)
- Readable font sizes (16px+ base)
- Optimized images (WebP format)
- Fast loading (<3s FCP)

## 🔒 Security

### Environment Variables
- Never commit `.env` to Git
- Use Vercel environment variables
- Rotate Supabase keys periodically

### Supabase RLS
- Ensure RLS enabled on all tables
- Test policies with anonymous users
- Use `auth.uid()` for user-specific data

## 🎨 Design System

### Colors
- **Primary**: `#10b981` (minecraft-emerald)
- **Secondary**: `#3b82f6` (minecraft-diamond)
- **Background**: `#0f172a` (gray-950)
- **Text**: `#f8fafc` (gray-50)

### Typography
- **Headings**: `font-bold`
- **Body**: `text-gray-400`
- **Links**: `text-minecraft-emerald`

## 🧪 Testing

```bash
# Development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 📊 Performance Optimization

### Bundle Size
- Lazy load routes with `React.lazy()`
- Code splitting per page
- Tree-shake unused dependencies

### Images
- Use WebP format
- Optimize with Squoosh/Sharp
- Lazy load images

### Caching
- Static assets cached (1 year)
- HTML no-cache for updates
- API responses cached (5 min)

## 🆘 Troubleshooting

### Build Fails
- Check Node version (18.x recommended)
- Clear `node_modules`: `rm -rf node_modules && npm install`
- Check TypeScript errors: `npm run lint`

### Environment Variables Not Working
- Restart Vercel deployment
- Verify variable names match code
- Check `.env` format (no quotes needed)

### Supabase Connection Issues
- Verify URL and anon key
- Check RLS policies
- Test in Supabase SQL Editor

### Mobile Layout Broken
- Check Tailwind breakpoints
- Test with Chrome DevTools mobile view
- Verify `viewport` meta tag

## 🚢 CI/CD Pipeline

Automatic deployment on:
- Push to `main` branch → Production
- Push to `develop` branch → Preview
- Pull requests → Preview deployments

## 📝 Maintenance

### Regular Updates
- Update dependencies monthly: `npm update`
- Security patches: `npm audit fix`
- Backup Supabase database weekly
- Monitor error logs in Vercel dashboard

### Content Updates
- Add new courses via Supabase SQL
- Update `courses.ts` for metadata
- Test new content in preview deploy

---

**Built with ❤️ for Ukrainian Minecraft Community**
