# cmp-variable-type

> [!WARNING]
> Currently experimental until v1.0.0 release.

Tree-sitter based [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) completion source for lowerCamelCase variable names based on type.

## Motivation

It's common to name variables after their type in strongly-typed languages such as Java.

For example, a variable name with the type `LinkedHashSet` could be `linkedHashSet`, `hashSet`, or `set`:

```java
LinkedHashSet l // suggests linkedHashSet
LinkedHashSet h // suggests hashSet
LinkedHashSet s // suggests set
```

Other editors such as VS Code also provide these completion suggestions.

## Supported Languages

Currently only supports Java. See [test/Test.java](./test/Test.java) for testing.

It should complete variables in the following places.

1. For fields declarations in class bodies:
```java
class Example {
    private final CompletableFuture f // suggest future
}
```


2. For parameter names in constructors:
```java
class Example {

    Example(CompletableFuture f) // suggest future

}
```

3. For parameter names in method declarations:
```java
class Example {

    private String getValue(CompletableFuture f) // suggest future

}
```

4. And for local variable names in method bodies:
```java
class Example {

    private String getValue() {
        CompletableFuture f // suggest future
    }

}
```

Pull requests are welcome for other languages like C#, Kotlin, and Scala.

## Limitations
Doesn't work for Java generic types. For example:
```java
LinkedHashSet<String> l // doesn't suggest linkedHashSet
```

This is due to the Java tree-sitter grammar parsing incomplete generic type declarations as binary expressions.

Changes to the [Java tree-sitter grammar](https://github.com/tree-sitter/tree-sitter-java) should be made before attempting to work around that.

