interface Func<T> {
    ([...args]: any, args2?: any): T;
}

export function returnType<T>(func: Func<T>) {
    return {} as T;
}