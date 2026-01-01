-- Complete Supabase Database Schema for Trip Management
-- Run this SQL in your Supabase SQL Editor

-- Enable UUID extension (PostgreSQL only)
-- If you are not using PostgreSQL, remove the following line.
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create drivers table
CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    email TEXT,
    license_number TEXT UNIQUE,
    rating DECIMAL(3,2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_trips INTEGER DEFAULT 0,
    profile_image TEXT,
    vehicle_id UUID,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create vehicles table
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model TEXT NOT NULL,
    brand TEXT NOT NULL,
    number_plate TEXT NOT NULL UNIQUE,
    seater_count INTEGER NOT NULL CHECK (seater_count > 0),
    color TEXT,
    fuel_type TEXT DEFAULT 'petrol',
    year_of_manufacture INTEGER,
    is_ac BOOLEAN DEFAULT TRUE,
    vehicle_type TEXT DEFAULT 'sedan' CHECK (vehicle_type IN ('sedan', 'suv', 'hatchback', 'luxury')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create trips table
CREATE TABLE IF NOT EXISTS public.trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.drivers(id),
    vehicle_id UUID REFERENCES public.vehicles(id),
    trip_type TEXT DEFAULT 'one_way' CHECK (trip_type IN ('one_way', 'round_trip', 'rental')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    
    -- Trip details
    pickup_location TEXT NOT NULL,
    pickup_latitude DECIMAL(10,8),
    pickup_longitude DECIMAL(11,8),
    drop_location TEXT NOT NULL,
    drop_latitude DECIMAL(10,8),
    drop_longitude DECIMAL(11,8),
    
    -- Scheduling
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    pickup_time TIMESTAMP WITH TIME ZONE,
    drop_time TIMESTAMP WITH TIME ZONE,
    
    -- Distance and duration
    estimated_distance DECIMAL(8,2), -- in KM
    actual_distance DECIMAL(8,2),
    estimated_duration INTEGER, -- in minutes
    actual_duration INTEGER,
    
    -- Pricing
    base_fare DECIMAL(10,2) NOT NULL DEFAULT 0,
    distance_fare DECIMAL(10,2) DEFAULT 0,
    time_fare DECIMAL(10,2) DEFAULT 0,
    toll_fee DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    amount_paid DECIMAL(10,2) DEFAULT 0,
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')),
    
    -- Additional info
    passenger_count INTEGER DEFAULT 1,
    special_instructions TEXT,
    cancellation_reason TEXT,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create trip_feedback table
CREATE TABLE IF NOT EXISTS public.trip_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.drivers(id),
    rating DECIMAL(3,2) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    feedback_type TEXT DEFAULT 'trip' CHECK (feedback_type IN ('trip', 'driver', 'vehicle', 'service')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create trip_issues table
CREATE TABLE IF NOT EXISTS public.trip_issues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    issue_type TEXT NOT NULL,
    description TEXT NOT NULL,
    status TEXT DEFAULT 'reported' CHECK (status IN ('reported', 'in_progress', 'resolved', 'closed')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Create trip_tracking table for live tracking
CREATE TABLE IF NOT EXISTS public.trip_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    speed DECIMAL(5,2) DEFAULT 0, -- in km/h
    heading DECIMAL(5,2) DEFAULT 0, -- in degrees
    accuracy DECIMAL(8,2), -- in meters
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Add foreign key constraint for driver vehicle
ALTER TABLE public.drivers 
ADD CONSTRAINT fk_driver_vehicle 
FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);

-- Enable Row Level Security
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_tracking ENABLE ROW LEVEL SECURITY;

-- RLS Policies for trips
CREATE POLICY "Users can view their own trips" ON public.trips
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own trips" ON public.trips
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own trips" ON public.trips
    FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for trip_feedback
CREATE POLICY "Users can view their own feedback" ON public.trip_feedback
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own feedback" ON public.trip_feedback
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for trip_issues
CREATE POLICY "Users can view their own issues" ON public.trip_issues
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own issues" ON public.trip_issues
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for drivers (read-only for users)
CREATE POLICY "Users can view active drivers" ON public.drivers
    FOR SELECT USING (is_active = true);

-- RLS Policies for vehicles (read-only for users)
CREATE POLICY "Users can view vehicles" ON public.vehicles
    FOR SELECT USING (true);

-- RLS Policies for trip_tracking
CREATE POLICY "Users can view tracking for their trips" ON public.trip_tracking
    FOR SELECT USING (
        trip_id IN (
            SELECT id FROM public.trips WHERE user_id = auth.uid()
        )
    );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_trips_user_id ON public.trips(user_id);
CREATE INDEX IF NOT EXISTS idx_trips_status ON public.trips(status);
CREATE INDEX IF NOT EXISTS idx_trips_scheduled_date ON public.trips(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_trips_driver_id ON public.trips(driver_id);
CREATE INDEX IF NOT EXISTS idx_trip_feedback_trip_id ON public.trip_feedback(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_issues_trip_id ON public.trip_issues(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_tracking_trip_id ON public.trip_tracking(trip_id);
CREATE INDEX IF NOT EXISTS idx_drivers_active ON public.drivers(is_active);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER set_drivers_updated_at
    BEFORE UPDATE ON public.drivers
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_vehicles_updated_at
    BEFORE UPDATE ON public.vehicles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_trips_updated_at
    BEFORE UPDATE ON public.trips
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Insert sample data for testing
INSERT INTO public.vehicles (id, model, brand, number_plate, seater_count, color, vehicle_type) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Swift', 'Maruti', 'KA01AB1234', 4, 'White', 'hatchback'),
    ('550e8400-e29b-41d4-a716-446655440002', 'Innova', 'Toyota', 'KA01CD5678', 7, 'Silver', 'suv'),
    ('550e8400-e29b-41d4-a716-446655440003', 'City', 'Honda', 'KA01EF9012', 4, 'Black', 'sedan');

INSERT INTO public.drivers (id, name, phone, email, rating, total_trips, vehicle_id) VALUES
    ('550e8400-e29b-41d4-a716-446655440011', 'Ravi Kumar', '+919876543210', 'ravi@example.com', 4.5, 150, '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440012', 'Suresh Babu', '+919876543211', 'suresh@example.com', 4.2, 120, '550e8400-e29b-41d4-a716-446655440002'),
    ('550e8400-e29b-41d4-a716-446655440013', 'Manjunath', '+919876543212', 'manju@example.com', 4.8, 200, '550e8400-e29b-41d4-a716-446655440003');
