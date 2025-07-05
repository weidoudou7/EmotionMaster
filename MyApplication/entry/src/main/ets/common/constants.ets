export interface DecorationInfo {
  title: string;
  desc: string;
  unlocked: boolean;
  image: Resource;
  reward?: number;
  action?: string;
}

// 全局用户ID存储
let globalUserId: number | null = 405;

/**
 * 设置用户ID
 */
export function setUserId(id: number): void {
  globalUserId = id;
  console.log('用户ID已保存:', id);
}

/**
 * 获取用户ID
 */
export function getUserId(): number | null {
  return globalUserId;
}

/**
 * 清除用户ID
 */
export function clearUserId(): void {
  globalUserId = null;
  console.log('用户ID已清除');
}

/**
 * 检查是否有用户ID
 */
export function hasUserId(): boolean {
  return globalUserId !== null;
}

export function chunkArray<T>(arr: T[], size: number): T[][] {
  const result: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    result.push(arr.slice(i, i + size));
  }
  return result;
}