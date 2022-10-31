package com.keencho.terraformsample.server;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

public enum DummyDataType {
    BOOK("책"), ANIMAL("동물"), COFFEE("커피");

    private final String name;

    DummyDataType(String name) {
        this.name = name;
    }

    public static List<?> listAll() {
        return Arrays.stream(DummyDataType.values()).map(i -> {
            var map = new HashMap<String, String>();
            map.put("name", i.name);
            map.put("value", i.toString());
            return map;
        }).collect(Collectors.toList());
    }
}
