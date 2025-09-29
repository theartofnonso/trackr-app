-- TRKR Supabase Database Schema
-- This replaces the AWS Amplify GraphQL schema with PostgreSQL tables

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Exercises table
CREATE TABLE IF NOT EXISTS public.exercises (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  owner UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Routine Plans table
CREATE TABLE IF NOT EXISTS public.routine_plans (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  owner UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Routine Templates table
CREATE TABLE IF NOT EXISTS public.routine_templates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  owner UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Routine Logs table
CREATE TABLE IF NOT EXISTS public.routine_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  owner UUID REFERENCES auth.users(id) ON DELETE CASCADE,
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

-- Exercises table policies (owner-based, matching Amplify auth rules)
CREATE POLICY "Users can view own exercises" ON public.exercises
  FOR SELECT USING (auth.uid() = owner);

CREATE POLICY "Users can insert own exercises" ON public.exercises
  FOR INSERT WITH CHECK (auth.uid() = owner);

CREATE POLICY "Users can update own exercises" ON public.exercises
  FOR UPDATE USING (auth.uid() = owner);

CREATE POLICY "Users can delete own exercises" ON public.exercises
  FOR DELETE USING (auth.uid() = owner);

-- Routine Plans table policies
CREATE POLICY "Users can view own routine plans" ON public.routine_plans
  FOR SELECT USING (auth.uid() = owner);

CREATE POLICY "Users can insert own routine plans" ON public.routine_plans
  FOR INSERT WITH CHECK (auth.uid() = owner);

CREATE POLICY "Users can update own routine plans" ON public.routine_plans
  FOR UPDATE USING (auth.uid() = owner);

CREATE POLICY "Users can delete own routine plans" ON public.routine_plans
  FOR DELETE USING (auth.uid() = owner);

-- Routine Templates table policies
CREATE POLICY "Users can view own routine templates" ON public.routine_templates
  FOR SELECT USING (auth.uid() = owner);

CREATE POLICY "Users can insert own routine templates" ON public.routine_templates
  FOR INSERT WITH CHECK (auth.uid() = owner);

CREATE POLICY "Users can update own routine templates" ON public.routine_templates
  FOR UPDATE USING (auth.uid() = owner);

CREATE POLICY "Users can delete own routine templates" ON public.routine_templates
  FOR DELETE USING (auth.uid() = owner);

-- Routine Logs table policies
CREATE POLICY "Users can view own routine logs" ON public.routine_logs
  FOR SELECT USING (auth.uid() = owner);

CREATE POLICY "Users can insert own routine logs" ON public.routine_logs
  FOR INSERT WITH CHECK (auth.uid() = owner);

CREATE POLICY "Users can update own routine logs" ON public.routine_logs
  FOR UPDATE USING (auth.uid() = owner);

CREATE POLICY "Users can delete own routine logs" ON public.routine_logs
  FOR DELETE USING (auth.uid() = owner);

-- Public read access for shared content (matching Amplify's public read with IAM)
-- This allows reading routine templates and logs for sharing functionality
CREATE POLICY "Public can view routine templates for sharing" ON public.routine_templates
  FOR SELECT USING (true);

CREATE POLICY "Public can view routine logs for sharing" ON public.routine_logs
  FOR SELECT USING (true);

CREATE POLICY "Public can view routine plans for sharing" ON public.routine_plans
  FOR SELECT USING (true);