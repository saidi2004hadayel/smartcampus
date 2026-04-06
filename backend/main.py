"""
SmartCampus Companion — FastAPI Backend
Port: 8003
"""
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from contextlib import asynccontextmanager
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta
import os

from routes import auth, announcements, events, timetable
from database import init_db, close_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield
    await close_db()


app = FastAPI(
    title="SmartCampus API",
    description="Backend for SmartCampus Companion mobile app",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(announcements.router, prefix="/api/announcements", tags=["Announcements"])
app.include_router(events.router, prefix="/api/events", tags=["Events"])
app.include_router(timetable.router, prefix="/api/timetable", tags=["Timetable"])


@app.get("/")
async def root():
    return {"message": "SmartCampus API is running", "version": "1.0.0"}


@app.get("/health")
async def health():
    return {"status": "ok", "timestamp": datetime.utcnow().isoformat()}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8003, reload=True)
