# Database Setup Instructions

## Error Resolution: Invalid Enum Value

The error you're encountering is:
```
PostgrestException(message: invalid input value for enum booking_ride_type_enum: "local", code: 22P02, details: Bad Request, hint: null)
```

This error occurs because the `booking_ride_type_enum` doesn't exist in your database, or the value "local" is not a valid enum value.

## Solution: Create the Bookings Table Schema

You need to run the following SQL in your Supabase SQL Editor (Dashboard -> SQL Editor):

### Step 1: Create Enum Types

```sql
-- Create enum types for booking fields
CREATE TYPE booking_ride_type_enum AS ENUM ('city', 'airport', 'outstation', 'hourly');
CREATE TYPE booking_status_enum AS ENUM ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled');
CREATE TYPE payment_status_enum AS ENUM ('pending', 'partial', 'completed', 'failed');
```

### Step 2: Create Bookings Table

```sql
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
```

### Step 3: Enable Row Level Security

```sql
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
```

### Step 4: Create Indexes

```sql
-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON public.bookings(created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_scheduled_time ON public.bookings(scheduled_time);
```

### Step 5: Create Supporting Tables (if needed)

```sql
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
```

## Valid Enum Values

After running the above SQL, the valid enum values will be:

### booking_ride_type_enum
- `'city'` - City/local rides
- `'airport'` - Airport transfers
- `'outstation'` - Outstation trips
- `'hourly'` - Hourly rentals

### booking_status_enum
- `'pending'` - Booking is pending
- `'confirmed'` - Booking is confirmed
- `'in_progress'` - Trip is in progress
- `'completed'` - Trip is completed
- `'cancelled'` - Booking is cancelled

### payment_status_enum
- `'pending'` - Payment is pending
- `'partial'` - Partial payment made
- `'completed'` - Payment completed
- `'failed'` - Payment failed

## Code Fix

The code has already been updated to use the correct enum values:
- `'city'` instead of `'local'`
- `'airport'` for airport bookings
- `'outstation'` for outstation bookings
- `'hourly'` for hourly rentals

## Testing

After setting up the database schema:

1. Run the SQL commands in your Supabase SQL Editor
2. Test the booking creation again
3. The error should be resolved

## Alternative: Use TEXT Instead of ENUM

If you prefer to use TEXT fields instead of ENUMs (for more flexibility), you can modify the table creation to use CHECK constraints:

```sql
-- Alternative: Use TEXT with CHECK constraints
CREATE TABLE IF NOT EXISTS public.bookings (
    -- ... other fields ...
    ride_type TEXT DEFAULT 'city' CHECK (ride_type IN ('city', 'airport', 'outstation', 'hourly')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'partial', 'completed', 'failed')),
    -- ... rest of fields ...
);
```

This approach gives you the same validation but with more flexibility for future changes.
