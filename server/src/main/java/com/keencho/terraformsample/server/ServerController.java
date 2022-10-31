package com.keencho.terraformsample.server;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@RestController
@RequestMapping("/api")
public class ServerController {

    @GetMapping("/getType")
    public List<?> getType() {
        return DummyDataType.listAll();
    }

    @GetMapping("/generateData")
    public List<?> generateData(@RequestParam("type") DummyDataType dummyDataType) {
        return IntStream.range(0, 30).mapToObj(idx -> FakerUtils.generateDataByType(dummyDataType)).collect(Collectors.toList());
    }
}
