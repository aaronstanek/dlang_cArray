module cArray;

import core.stdc.stdlib: malloc, realloc, free;
import std.algorithm.comparison: min;

@nogc @trusted struct cArray(T) {

    private:

    T * mem; // initialized to null
    size_t count; // initialized to 0

    public:

    // first make sure that this object can
    // never be copied

    @disable this(this);
    @disable void opAssign(this);

    // constructor and destructor

    this(size_t s) {
        if (s != 0) {
            mem = cast(T*) malloc(s * T.sizeof);
            count = s;
        }
    }

    ~this() {
        if (mem !is null) {
            free(mem);
        }
    }

    // wrappers for malloc, realloc, free

    void newArray(size_t s) {
        if (mem !is null) {
            free(mem);
        }
        if (s == 0) {
            mem = null;
            count = 0;
        }
        else {
            mem = cast(T*) malloc(s * T.sizeof);
            count = s;
        }
    }

    void resize(size_t s) {
        if (mem is null) {
            if (s == 0) {
                // mem is null, s is 0
                // do nothing
            }
            else {
                // mem is null, s > 0
                mem = cast(T*) malloc(s * T.sizeof);
                count = s;
            }
        }
        else {
            if (s == 0) {
                // mem is defined, s is 0
                free(mem);
                mem = null;
                count = 0;
            }
            else {
                // mem is defined, s > 0
                mem = cast(T*) realloc(mem , s * T.sizeof);
                count = s;
            }
        }
    }

    void clear() {
        if (mem !is null) {
            free(mem);
            mem = null;
            count = 0;
        }
    }

    // reserve functions

    void reserve_new(size_t s) {
        if (s == 0 || count >= s) {
            return;
        }
        if (mem !is null) {
            free(mem);
        }
        mem = cast(T*) malloc(s * T.sizeof);
        count = s;
    }

    void reserve_resize(size_t s) {
        if (s == 0 || count >= s) {
            return;
        }
        if (mem is null) {
            mem = cast(T*) malloc(s * T.sizeof);
        }
        else {
            mem = cast(T*) realloc(mem , s * T.sizeof);
        }
        count = s;
    }

    // functions to allow resizing and copying in one step

    void copy_exact(ref cArray!T other) {
        size_t s = other.count;
        if (s == 0) {
            if (mem !is null) {
                free(mem);
            }
            mem = null;
            count = 0;
            return;
        }
        if (count != s) {
            if (mem !is null) {
                free(mem);
            }
            mem = cast(T*) malloc(s * T.sizeof);
            count = s;
        }
        mem[0..s] = other.mem[0..s];
    }

    void copy_exact(T[] other) {
        size_t s = other.length;
        if (s == 0) {
            if (mem !is null) {
                free(mem);
            }
            mem = null;
            count = 0;
            return;
        }
        if (count != s) {
            if (mem !is null) {
                free(mem);
            }
            mem = cast(T*) malloc(s * T.sizeof);
            count = s;
        }
        mem[0..s] = other[0..s];
    }

    void copy_reserve(ref cArray!T other) {
        size_t s = other.count;
        if (s == 0) {
            return;
        }
        if (count < s) {
            if (mem !is null) {
                free(mem);
            }
            mem = cast(T*) malloc(s * T.sizeof);
            count = s;
        }
        mem[0..s] = other.mem[0..s];
    }

    void copy_reserve(T[] other) {
        size_t s = other.length;
        if (s == 0) {
            return;
        }
        if (count < s) {
            if (mem !is null) {
                free(mem);
            }
            mem = cast(T*) malloc(s * T.sizeof);
            count = s;
        }
        mem[0..s] = other[0..s];
    }

    // functions to allow truncated copying

    void copy_trunc(ref cArray!T other) {
        size_t s = min(count,other.count);
        if (s != 0) {
            mem[0..s] = other.mem[0..s];
        }
    }

    void copy_trunc(T[] other) {
        size_t s = min(count,other.length);
        if (s != 0) {
            mem[0..s] = other[0..s];
        }
    }

    // manipulating elements

    ref T opIndex(size_t i) {
        return mem[i];
    }

    void opIndexAssign(T value, size_t spot) {
        mem[spot] = value;
    }

    // manipulating slices

    T[] opSlice(size_t start, size_t end) {
        return mem[start..end];
    }

    T[] opSlice(size_t start) {
        return mem[start..count];
    }

    T[] opSlice() {
        return mem[0..count];
    }

    void opIndexAssign(T[] value, size_t spot) {
        mem[spot..spot+value.length] = value;
    }

    void opIndexAssign(T[] value) {
        mem[0..value.length] = value;
    }

    // and functions to get the length

    size_t opDollar() {
        return count;
    }

    size_t length() {
        return count;
    }

}
