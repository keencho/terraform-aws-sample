package com.keencho.terraformsample.server;

import net.datafaker.Faker;

import java.util.HashMap;
import java.util.Map;

public class FakerUtils {
    private static final Faker faker;

    static {
        faker = new Faker();
    }

    public static Map<String, String> generateDataByType(DummyDataType type) {
        return switch (type) {
            case BOOK -> generateBook();
            case ANIMAL -> generateAnimal();
            case COFFEE -> generateCoffee();
        };
    }

    private static Map<String, String> generateCoffee() {
        var map = new HashMap<String, String>();
        var coffee = faker.coffee();

        map.put("name1", coffee.name1());
        map.put("name2", coffee.name2());
        map.put("blendName", coffee.blendName());
        map.put("body", coffee.body());
        map.put("country", coffee.country());
        map.put("region", coffee.region());

        return map;
    }

    private static Map<String, String> generateAnimal() {
        var map = new HashMap<String, String>();
        var animal = faker.animal();

        map.put("name", animal.name());
        map.put("genus", animal.genus());
        map.put("species", animal.species());

        return map;
    }

    private static Map<String, String> generateBook() {
        var map = new HashMap<String, String>();
        var book = faker.book();

        map.put("title", book.title());
        map.put("author", book.author());
        map.put("genre", book.genre());
        map.put("publisher", book.publisher());

        return map;
    }
}
