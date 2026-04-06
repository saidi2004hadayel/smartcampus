"""
Announcements CRUD routes
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from bson import ObjectId
from datetime import datetime
from typing import List, Optional

from database import get_db
from schemas import AnnouncementOut, AnnouncementCreate
from dependencies import get_current_user

router = APIRouter()


def doc_to_out(doc: dict) -> AnnouncementOut:
    return AnnouncementOut(
        id=str(doc["_id"]),
        title=doc["title"],
        body=doc["body"],
        category=doc.get("category", "general"),
        author=doc.get("author", "Admin"),
        created_at=doc.get("created_at", datetime.utcnow()),
        is_important=doc.get("is_important", False),
    )


@router.get("/", response_model=List[AnnouncementOut])
async def list_announcements(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, le=100),
    category: Optional[str] = None,
    current_user: dict = Depends(get_current_user),
):
    db = get_db()
    query = {}
    if category:
        query["category"] = category

    cursor = db.announcements.find(query).sort("created_at", -1).skip(skip).limit(limit)
    docs = await cursor.to_list(length=limit)
    return [doc_to_out(d) for d in docs]


@router.get("/{announcement_id}", response_model=AnnouncementOut)
async def get_announcement(
    announcement_id: str,
    current_user: dict = Depends(get_current_user),
):
    db = get_db()
    doc = await db.announcements.find_one({"_id": ObjectId(announcement_id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Announcement not found")
    return doc_to_out(doc)


@router.post("/", response_model=AnnouncementOut, status_code=201)
async def create_announcement(
    payload: AnnouncementCreate,
    current_user: dict = Depends(get_current_user),
):
    db = get_db()
    doc = {
        **payload.dict(),
        "author": current_user["full_name"],
        "created_at": datetime.utcnow(),
    }
    result = await db.announcements.insert_one(doc)
    doc["_id"] = result.inserted_id
    return doc_to_out(doc)
