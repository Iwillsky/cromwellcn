task echoHello{
    command {
        echo "Hello AWS!"
    }
    runtime {
        docker: "amazonlinux:latest"
    }

}

workflow printHelloAndGoodbye {
    call echoHello
}

