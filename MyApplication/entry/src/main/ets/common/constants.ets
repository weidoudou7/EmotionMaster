export interface DecorationInfo {
  title: string;
  desc: string;
  unlocked: boolean;
  image: Resource;
  reward?: number;
  action?: string;
}

export function chunkArray<T>(arr: T[], size: number): T[][] {
  const result: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    result.push(arr.slice(i, i + size));
  }
  return result;
}