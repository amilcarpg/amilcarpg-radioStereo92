pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}

gradle.toolchains {
    jvm {
        javaLauncher.set(file("C:\\Program Files\\OpenLogic\\jdk-21.0.6.7-hotspot\\bin\\java.exe")) // Ruta específica al ejecutable de Java 21
    }
}