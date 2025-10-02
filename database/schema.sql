-- TRKR Supabase Database Schema
-- This replaces the AWS Amplify GraphQL schema with PostgreSQL tables

-- Exercises table
CREATE TABLE IF NOT EXISTS public.exercises (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Routine Plans table
CREATE TABLE IF NOT EXISTS public.routine_plans (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Routine Templates table
CREATE TABLE IF NOT EXISTS public.routine_templates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Routine Logs table
CREATE TABLE IF NOT EXISTS public.routine_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  data JSONB NOT NULL,
  type TEXT DEFAULT 'RoutineLog',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security (RLS) Policies
-- Enable RLS on all tables
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_logs ENABLE ROW LEVEL SECURITY;

-- Public access policies (no ownership restrictions)
-- All users can view, insert, update, and delete all records

-- Exercises table policies
CREATE POLICY "Public can view exercises" ON public.exercises
  FOR SELECT USING (true);

CREATE POLICY "Public can insert exercises" ON public.exercises
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Public can update exercises" ON public.exercises
  FOR UPDATE USING (true);

CREATE POLICY "Public can delete exercises" ON public.exercises
  FOR DELETE USING (true);

-- Routine Plans table policies
CREATE POLICY "Public can view routine plans" ON public.routine_plans
  FOR SELECT USING (true);

CREATE POLICY "Public can insert routine plans" ON public.routine_plans
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Public can update routine plans" ON public.routine_plans
  FOR UPDATE USING (true);

CREATE POLICY "Public can delete routine plans" ON public.routine_plans
  FOR DELETE USING (true);

-- Routine Templates table policies
CREATE POLICY "Public can view routine templates" ON public.routine_templates
  FOR SELECT USING (true);

CREATE POLICY "Public can insert routine templates" ON public.routine_templates
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Public can update routine templates" ON public.routine_templates
  FOR UPDATE USING (true);

CREATE POLICY "Public can delete routine templates" ON public.routine_templates
  FOR DELETE USING (true);

-- Routine Logs table policies
CREATE POLICY "Public can view routine logs" ON public.routine_logs
  FOR SELECT USING (true);

CREATE POLICY "Public can insert routine logs" ON public.routine_logs
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Public can update routine logs" ON public.routine_logs
  FOR UPDATE USING (true);

CREATE POLICY "Public can delete routine logs" ON public.routine_logs
  FOR DELETE USING (true);