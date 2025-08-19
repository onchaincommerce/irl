import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';

// In-memory storage for MVP (replace with database in production)
const claims = new Map<string, any>();

export async function POST(request: NextRequest) {
  try {
    const { amount, token = 'USDC' } = await request.json();
    
    if (!amount || amount <= 0) {
      return NextResponse.json(
        { error: 'Invalid amount' },
        { status: 400 }
      );
    }

    // Generate claim data
    const claimId = crypto.randomUUID();
    const secret = crypto.randomBytes(16).toString('base64');
    const secretHash = crypto.createHash('sha256').update(secret).digest('hex');
    const expiry = Math.floor(Date.now() / 1000) + (24 * 60 * 60); // 24 hours from now

    const claim = {
      claimId,
      secretHash,
      amount: parseFloat(amount),
      token,
      status: 'pending',
      createdAt: new Date().toISOString(),
      expiry
    };

    claims.set(claimId, claim);

    // Return only the data needed by the client
    return NextResponse.json({
      claimId,
      secret,
      expiry,
      amount: claim.amount,
      token: claim.token
    });

  } catch (error) {
    console.error('Error creating claim:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const claimId = searchParams.get('claimId');

    if (!claimId) {
      return NextResponse.json(
        { error: 'Claim ID is required' },
        { status: 400 }
      );
    }

    const claim = claims.get(claimId);
    if (!claim) {
      return NextResponse.json(
        { error: 'Claim not found' },
        { status: 404 }
      );
    }

    // Don't return sensitive data like secretHash
    return NextResponse.json({
      claimId: claim.claimId,
      amount: claim.amount,
      token: claim.token,
      status: claim.status,
      createdAt: claim.createdAt,
      expiry: claim.claim
    });

  } catch (error) {
    console.error('Error retrieving claim:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
