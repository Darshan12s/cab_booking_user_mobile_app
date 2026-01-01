-- Complete Supabase Schema for Cab Booking App
-- Run this SQL in your Supabase SQL Editor (Dashboard -> SQL Editor)

-- Create the addresses table for My Address screen
CREATE TABLE IF NOT EXISTS public.addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    building_no TEXT NOT NULL,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    type TEXT NOT NULL CHECK (type IN ('HOME', 'WORK', 'Other')),
    other_type TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable Row Level Security
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;

-- Create policy for users to only see their own addresses
CREATE POLICY "Users can view their own addresses" ON public.addresses
    FOR SELECT USING (auth.uid() = user_id);

-- Create policy for users to insert their own addresses
CREATE POLICY "Users can insert their own addresses" ON public.addresses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own addresses
CREATE POLICY "Users can update their own addresses" ON public.addresses
    FOR UPDATE USING (auth.uid() = user_id);

-- Create policy for users to delete their own addresses
CREATE POLICY "Users can delete their own addresses" ON public.addresses
    FOR DELETE USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON public.addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_addresses_is_default ON public.addresses(user_id, is_default);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.addresses
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create user_locations table for map functionality
CREATE TABLE IF NOT EXISTS public.user_locations (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT,
    location_type TEXT DEFAULT 'saved' CHECK (location_type IN ('pickup', 'dropoff', 'saved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable RLS for user_locations
ALTER TABLE public.user_locations ENABLE ROW LEVEL SECURITY;

-- Policies for user_locations
CREATE POLICY "Users can view their own locations" ON public.user_locations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own locations" ON public.user_locations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own locations" ON public.user_locations
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own locations" ON public.user_locations
    FOR DELETE USING (auth.uid() = user_id);

-- Create live_tracking table for real-time location tracking
CREATE TABLE IF NOT EXISTS public.live_tracking (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    heading DOUBLE PRECISION DEFAULT 0,
    speed DOUBLE PRECISION DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable RLS for live_tracking
ALTER TABLE public.live_tracking ENABLE ROW LEVEL SECURITY;

-- Policies for live_tracking
-- The following policies require PostgreSQL (Supabase) to work.
CREATE POLICY "Users can view their own tracking" ON public.live_tracking
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tracking" ON public.live_tracking
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tracking" ON public.live_tracking
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tracking" ON public.live_tracking
    FOR DELETE USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_locations_user_id ON public.user_locations(user_id);
CREATE INDEX IF NOT EXISTS idx_user_locations_created_at ON public.user_locations(created_at);
CREATE INDEX IF NOT EXISTS idx_live_tracking_user_id ON public.live_tracking(user_id);
CREATE INDEX IF NOT EXISTS idx_live_tracking_active ON public.live_tracking(user_id, is_active);

-- Add updated_at trigger to user_locations
CREATE TRIGGER set_user_locations_updated_at
    BEFORE UPDATE ON public.user_locations
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Add updated_at trigger to live_tracking
CREATE TRIGGER set_live_tracking_updated_at
    BEFORE UPDATE ON public.live_tracking
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
