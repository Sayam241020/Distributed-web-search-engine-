#!/bin/bash
"""
Complete cleanup script - Wipes MongoDB AND Redis.
Use this before starting a fresh crawl with new seed URLs.
"""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧹 COMPLETE CRAWLER CLEANUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Stop any running workers first
echo "🛑 Stopping workers..."
"$PROJECT_ROOT/scripts/stop_v3.sh"
sleep 2

# Clean MongoDB
echo ""
echo "🗑️  Cleaning MongoDB..."
python3 "$PROJECT_ROOT/src/utils/cleanup_mongodb.py" --confirm

# Clean Redis
echo ""
echo "🗑️  Cleaning Redis..."
echo "   Deleting crawler:frontier..."
redis-cli DEL crawler:frontier > /dev/null

echo "   Deleting crawler:bloom_filter..."
redis-cli DEL crawler:bloom_filter > /dev/null

echo "   Deleting robots.txt cache..."
redis-cli --scan --pattern "robots_cache:*" | xargs -L 100 redis-cli DEL > /dev/null 2>&1

echo "   Deleting domain metadata..."
redis-cli --scan --pattern "domain:*" | xargs -L 100 redis-cli DEL > /dev/null 2>&1

echo "   Deleting domain locks..."
redis-cli --scan --pattern "lock:*" | xargs -L 100 redis-cli DEL > /dev/null 2>&1

# Verify cleanup
FRONTIER_COUNT=$(redis-cli ZCARD crawler:frontier)
BLOOM_EXISTS=$(redis-cli EXISTS crawler:bloom_filter)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CLEANUP COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Status:"
echo "  ✅ MongoDB: Cleaned"
echo "  ✅ Redis frontier: $FRONTIER_COUNT URLs (should be 0)"
echo "  ✅ Redis Bloom Filter: $([ $BLOOM_EXISTS -eq 0 ] && echo 'Deleted' || echo 'Still exists')"
echo ""
echo "Ready for fresh crawl! Run:"
echo "  ./scripts/start_v3.sh"
echo ""
