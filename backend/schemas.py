"""
Pydantic schemas for request/response validation
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


# ─── Auth ────────────────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=6)
    student_id: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds
    user: "UserOut"

class UserOut(BaseModel):
    id: str
    full_name: str
    email: str
    student_id: Optional[str] = None

class RefreshTokenRequest(BaseModel):
    refresh_token: str


# ─── Announcements ────────────────────────────────────────────────────────────

class AnnouncementCategory(str, Enum):
    general = "general"
    academic = "academic"
    facilities = "facilities"
    it = "it"
    safety = "safety"

class AnnouncementOut(BaseModel):
    id: str
    title: str
    body: str
    category: str
    author: str
    created_at: datetime
    is_important: bool = False

class AnnouncementCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=200)
    body: str = Field(..., min_length=10)
    category: AnnouncementCategory = AnnouncementCategory.general
    is_important: bool = False


# ─── Events ───────────────────────────────────────────────────────────────────

class EventOut(BaseModel):
    id: str
    title: str
    description: str
    location: str
    event_date: datetime
    category: str
    organizer: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class EventCreate(BaseModel):
    title: str = Field(..., min_length=3)
    description: str
    location: str
    event_date: datetime
    category: str = "general"
    latitude: Optional[float] = None
    longitude: Optional[float] = None


# ─── Timetable ────────────────────────────────────────────────────────────────

class TimetableEntry(BaseModel):
    id: str
    course_code: str
    course_name: str
    room: str
    professor: str
    day_of_week: int  # 0=Mon, 6=Sun
    start_time: str   # "HH:MM"
    end_time: str
    type: str         # "lecture", "lab", "tutorial"
