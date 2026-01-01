-- Bookings Table Schema for Cab Booking App
-- Run this SQL in your Supabase SQL Editor (Dashboard -> SQL Editor)

-- Create enum types for booking fields
CREATE TYPE booking_ride_type_enum AS ENUM ('city', 'airport', 'outstation', 'hourly');
CREATE TYPE booking_status_enum AS ENUM ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled');
CREATE TYPE payment_status_enum AS ENUM ('pending', 'partial', 'completed', 'failed');

-- Create bookings table
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.drivers(id),
    vehicle_id UUID REFERENCES public.vehicles(id),
    
    -- Location information
    pickup_latitude DECIMAL(10,8),
    pickup_longitude DECIMAL(11,8),
    dropoff_latitude DECIMAL(10,8),
    dropoff_longitude DECIMAL(11,8),
    pickup_address TEXT NOT NULL,
    dropoff_address TEXT NOT NULL,
    pickup_location_id UUID,
    dropoff_location_id UUID,
    
    -- Trip details
    fare_amount DECIMAL(10,2),
    distance_km DECIMAL(8,2),
    ride_type booking_ride_type_enum NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    
    -- Status and payment
    status booking_status_enum DEFAULT 'pending',
    payment_status payment_status_enum DEFAULT 'pending',
    payment_method TEXT DEFAULT 'card',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    
    -- Service and package information
    service_type_id UUID,
    rental_package_id UUID,
    zone_pricing_id UUID,
    
    -- Scheduling
    scheduled_time TIMESTAMP WITH TIME ZONE,
    is_scheduled BOOLEAN DEFAULT FALSE,
    is_shared BOOLEAN DEFAULT FALSE,
    sharing_group_id UUID,
    
    -- Trip details
    total_stops INTEGER DEFAULT 0,
    package_hours INTEGER,
    included_km INTEGER,
    extra_km_used DECIMAL(8,2) DEFAULT 0,
    extra_hours_used DECIMAL(8,2) DEFAULT 0,
    waiting_time_minutes INTEGER DEFAULT 0,
    
    -- Cancellation and issues
    cancellation_reason TEXT,
    no_show_reason TEXT,
    upgrade_charges DECIMAL(10,2) DEFAULT 0,
    
    -- Round trip information
    is_round_trip BOOLEAN DEFAULT FALSE,
    return_scheduled_time TIMESTAMP WITH TIME ZONE,
    
    -- Additional details
    trip_type TEXT,
    vehicle_type TEXT,
    special_instructions TEXT,
    advance_amount DECIMAL(10,2),
    remaining_amount DECIMAL(10,2)
);

-- Enable Row Level Security
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Create policies for bookings
CREATE POLICY "Users can view their own bookings" ON public.bookings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own bookings" ON public.bookings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own bookings" ON public.bookings
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own bookings" ON public.bookings
    FOR DELETE USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON public.bookings(created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_scheduled_time ON public.bookings(scheduled_time);

-- Add updated_at trigger
CREATE TRIGGER set_bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create drivers table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    vehicle_id UUID REFERENCES public.vehicles(id),
    license_number TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    current_latitude DECIMAL(10,8),
    current_longitude DECIMAL(11,8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create vehicles table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_number TEXT NOT NULL UNIQUE,
    model TEXT NOT NULL,
    type TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable RLS for drivers and vehicles
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

-- Create policies for drivers
CREATE POLICY "Drivers can view their own data" ON public.drivers
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Drivers can update their own data" ON public.drivers
    FOR UPDATE USING (auth.uid() = user_id);

-- Create policies for vehicles (admin only for now)
CREATE POLICY "Admin can manage vehicles" ON public.vehicles
    FOR ALL USING (auth.role() = 'admin');

-- Add updated_at triggers
CREATE TRIGGER set_drivers_updated_at
    BEFORE UPDATE ON public.drivers
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_vehicles_updated_at
    BEFORE UPDATE ON public.vehicles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

