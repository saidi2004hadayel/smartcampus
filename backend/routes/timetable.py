"""
Timetable routes
"""
from fastapi import APIRouter, Depends, Query
from typing import List, Optional
from bson import ObjectId

from database import get_db
from schemas import TimetableEntry
from dependencies import get_current_user

router = APIRouter()


def doc_to_out(doc: dict) -> TimetableEntry:
    return TimetableEntry(
        id=str(doc["_id"]),
        course_code=doc["course_code"],
        course_name=doc["course_name"],
        room=doc["room"],
        professor=doc["professor"],
        day_of_week=doc["day_of_week"],
        start_time=doc["start_time"],
        end_time=doc["end_time"],
        type=doc.get("type", "lecture"),
    )


@router.get("/", response_model=List[TimetableEntry])
async def get_timetable(
    day: Optional[int] = Query(None, ge=0, le=6),
    current_user: dict = Depends(get_current_user),
):
    db = get_db()
    query = {}
    if day is not None:
        query["day_of_week"] = day

    cursor = db.timetable.find(query).sort([("day_of_week", 1), ("start_time", 1)])
    docs = await cursor.to_list(length=100)
    return [doc_to_out(d) for d in docs]
