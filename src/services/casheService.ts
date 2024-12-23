export class UserCache {
    private static instance: UserCache;
    private cache: Map<string, any>;
    private readonly TTL = 5 * 60 * 1000; // 5 minutes

    private constructor() {
        this.cache = new Map();
        this.startCleanupInterval();
    }

    public static getInstance(): UserCache {
        if (!UserCache.instance) {
            UserCache.instance = new UserCache();
        }
        return UserCache.instance;
    }

    set(key: string, value: any) {
        this.cache.set(key, {
            value,
            timestamp: Date.now()
        });
    }

    get(key: string) {
        const entry = this.cache.get(key);
        if (!entry) return null;

        if (Date.now() - entry.timestamp > this.TTL) {
            this.cache.delete(key);
            return null;
        }

        return entry.value;
    }

    private startCleanupInterval() {
        setInterval(() => {
            for (const [key, entry] of this.cache.entries()) {
                if (Date.now() - entry.timestamp > this.TTL) {
                    this.cache.delete(key);
                }
            }
        }, this.TTL);
    }
}