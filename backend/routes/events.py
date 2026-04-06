"""
Events routes
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from bson import ObjectId
from datetime import datetime
from typing import List

from database import get_db
from schemas import EventOut, EventCreate
from dependencies import get_current_user

router = APIRouter()


def doc_to_out(doc: dict) -> EventOut:
    return EventOut(
        id=str(doc["_id"]),
        title=doc["title"],
        description=doc["description"],
        location=doc["location"],
        event_date=doc["event_date"],
        category=doc.get("category", "general"),
        organizer=doc.get("organizer", "University"),
        latitude=doc.get("latitude"),
        longitude=doc.get("longitude"),
    )


@router.get("/", response_model=List[EventOut])
async def list_events(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, le=100),
    current_user: dict = Depends(get_current_user),
):
    db = get_db()
    cursor = db.events.find(
        {"event_date": {"$gte": datetime.utcnow()}}
    ).sort("event_date", 1).skip(skip).limit(limit)
    docs = await cursor.to_list(length=limit)
    return [doc_to_out(d) for d in docs]


@router.post("/", response_model=EventOut, status_code=201)
async def create_event(
    payload: EventCreate,
    current_user: dict = Depends(get_current_user),
):
    db = get_db()
    doc = {**payload.dict(), "organizer": current_user["full_name"]}
    result = await db.events.insert_one(doc)
    doc["_id"] = result.inserted_id
    return doc_to_out(doc)
