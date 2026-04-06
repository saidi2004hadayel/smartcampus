"""
Authentication routes: register, login, refresh, logout
"""
from fastapi import APIRouter, HTTPException, status, Depends
from bson import ObjectId
from datetime import timedelta

from database import get_db
from schemas import UserRegister, UserLogin, TokenResponse, UserOut
from auth_utils import hash_password, verify_password, create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES
from dependencies import get_current_user

router = APIRouter()


def user_to_out(user: dict) -> UserOut:
    return UserOut(
        id=str(user["_id"]),
        full_name=user["full_name"],
        email=user["email"],
        student_id=user.get("student_id"),
    )


@router.post("/register", status_code=201)
async def register(payload: UserRegister):
    db = get_db()
    existing = await db.users.find_one({"email": payload.email})
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_doc = {
        "full_name": payload.full_name,
        "email": payload.email,
        "password_hash": hash_password(payload.password),
        "student_id": payload.student_id,
        "role": "student",
    }
    result = await db.users.insert_one(user_doc)
    user_doc["_id"] = result.inserted_id

    token = create_access_token({"sub": str(result.inserted_id)})
    return TokenResponse(
        access_token=token,
        expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=user_to_out(user_doc),
    )


@router.post("/login")
async def login(payload: UserLogin):
    db = get_db()
    user = await db.users.find_one({"email": payload.email})
    if not user or not verify_password(payload.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token({"sub": str(user["_id"])})
    return TokenResponse(
        access_token=token,
        expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=user_to_out(user),
    )


@router.get("/me")
async def me(current_user: dict = Depends(get_current_user)):
    return user_to_out(current_user)


@router.post("/logout")
async def logout(current_user: dict = Depends(get_current_user)):
    # Stateless JWT — client discards token.
    # For production, add a token blacklist in Redis.
    return {"message": "Logged out successfully"}
