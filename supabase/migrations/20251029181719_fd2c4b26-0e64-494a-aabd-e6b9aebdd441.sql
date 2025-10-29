-- =====================================================
-- GALLERY MANAGEMENT SYSTEM
-- =====================================================
-- Creates table and storage for gallery images

-- =====================================================
-- STEP 1: Create Storage Bucket for Gallery Images
-- =====================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('gallery-images', 'gallery-images', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STEP 2: Create Gallery Images Table
-- =====================================================
CREATE TABLE public.gallery_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url TEXT NOT NULL,
  title TEXT,
  description TEXT,
  alt_text TEXT,
  display_order INTEGER DEFAULT 0,
  is_visible BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable RLS
ALTER TABLE public.gallery_images ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 3: RLS Policies for Gallery Images
-- =====================================================
-- Public can view visible images
CREATE POLICY "Anyone can view visible gallery images"
ON gallery_images FOR SELECT
USING (is_visible = true);

-- Admins can manage all gallery images
CREATE POLICY "Admins can manage gallery images"
ON gallery_images FOR ALL
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- =====================================================
-- STEP 4: Storage Policies for Gallery Bucket
-- =====================================================
-- Anyone can view gallery images (public bucket)
CREATE POLICY "Anyone can view gallery images"
ON storage.objects FOR SELECT
USING (bucket_id = 'gallery-images');

-- Admins can upload gallery images
CREATE POLICY "Admins can upload gallery images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'gallery-images' AND
  public.is_admin()
);

-- Admins can update gallery images
CREATE POLICY "Admins can update gallery images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'gallery-images' AND
  public.is_admin()
);

-- Admins can delete gallery images
CREATE POLICY "Admins can delete gallery images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'gallery-images' AND
  public.is_admin()
);

-- =====================================================
-- STEP 5: Add Auto-Update Trigger
-- =====================================================
CREATE TRIGGER update_gallery_images_updated_at
BEFORE UPDATE ON gallery_images
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();