#Bucket to store website
resource "google_storage_bucket" "website" {
    name     = "example-website-by-alif"
    location = "US"
}

#make new object public
resource "google_storage_object_access_control" "public_rule" {
    object = google_storage_bucket_object.static_site_src.name
    bucket = google_storage_bucket.website.name
    role   = "READER"
    entity = "allUsers"
}

#upload html file to the bucket
resource "google_storage_bucket_object" "website" {
    name   = "index.html"
    bucket = google_storage_bucket.website.name
    source = "../website/index.html"
}
