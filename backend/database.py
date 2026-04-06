"""
MongoDB connection using Motor (async driver)
"""
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import IndexModel, ASCENDING
import os

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
DB_NAME = os.getenv("DB_NAME", "smartcampus")

client: AsyncIOMotorClient = None
db = None


async def init_db():
    global client, db
    client = AsyncIOMotorClient(MONGO_URL)
    db = client[DB_NAME]

    # Create indexes
    await db.users.create_index("email", unique=True)
    await db.announcements.create_index([("created_at", -1)])
    await db.events.create_index([("event_date", 1)])
    await db.timetable.create_index([("user_id", 1), ("day_of_week", 1)])

    # Seed sample data if empty
    if await db.announcements.count_documents({}) == 0:
        await seed_data()

    print(f"[DB] Connected to MongoDB at {MONGO_URL}")


async def close_db():
    global client
    if client:
        client.close()
        print("[DB] MongoDB connection closed")


def get_db():
    return db


async def seed_data():
    """Insert sample data for demo purposes."""
    from datetime import datetime, timedelta

    announcements = [
        {
            "title": "Welcome to Fall Semester 2025",
            "body": "Dear students, welcome back! Please check your timetables for any changes.",
            "category": "general",
            "author": "Administration",
            "created_at": datetime.utcnow() - timedelta(days=2),
            "is_important": True,
        },
        {
            "title": "Library Extended Hours",
            "body": "The university library will be open 24/7 during exam season (Dec 1-20).",
            "category": "facilities",
            "author": "Library Services",
            "created_at": datetime.utcnow() - timedelta(days=1),
            "is_important": False,
        },
        {
            "title": "Network Maintenance — Sunday 2AM",
            "body": "Campus WiFi will be down for maintenance this Sunday from 2AM to 5AM.",
            "category": "it",
            "author": "IT Department",
            "created_at": datetime.utcnow(),
            "is_important": True,
        },
    ]

    events = [
        {
            "title": "Career Fair 2025",
            "description": "Meet top employers from tech, finance, and engineering sectors.",
            "location": "Main Hall, Building A",
            "event_date": datetime.utcnow() + timedelta(days=5),
            "category": "career",
            "organizer": "Career Services",
            "latitude": 36.1901,
            "longitude": 5.4042,
        },
        {
            "title": "AI Research Symposium",
            "description": "Presentations by faculty on cutting-edge AI research projects.",
            "location": "Amphitheatre, CS Building",
            "event_date": datetime.utcnow() + timedelta(days=10),
            "category": "academic",
            "organizer": "CS Department",
            "latitude": 36.1905,
            "longitude": 5.4050,
        },
    ]

    timetable_entries = [
        {
            "course_code": "CS301",
            "course_name": "Mobile Operating Systems",
            "room": "Lab 204",
            "professor": "Dr. Benali",
            "day_of_week": 0,  # Monday
            "start_time": "08:00",
            "end_time": "09:30",
            "type": "lecture",
        },
        {
            "course_code": "CS302",
            "course_name": "Database Systems",
            "room": "Room 110",
            "professor": "Dr. Messaoud",
            "day_of_week": 1,  # Tuesday
            "start_time": "10:00",
            "end_time": "11:30",
            "type": "lecture",
        },
        {
            "course_code": "CS301",
            "course_name": "Mobile OS — Lab",
            "room": "Lab 204",
            "professor": "Dr. Benali",
            "day_of_week": 3,  # Thursday
            "start_time": "14:00",
            "end_time": "16:00",
            "type": "lab",
        },
    ]

    await db.announcements.insert_many(announcements)
    await db.events.insert_many(events)
    await db.timetable.insert_many(timetable_entries)
    print("[DB] Sample data seeded.")
