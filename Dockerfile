FROM golang AS builder
RUN git clone https://github.com/golang/pkgsite && \
    cd pkgsite && \
    git checkout 94d940ab81bcb78978c6f28b8a265b418a7054e0 && \
    sed -i 's|addr := cfg.HostAddr("localhost:8080")|addr := cfg.HostAddr("0.0.0.0:8080")|' cmd/frontend/main.go && \
    sed -i 's|od.Redistributable = false|od.Redistributable = true|' internal/frontend/overview.go && \
    sed -i 's|Redistributable:  vdir.Directory.IsRedistributable,|Redistributable: true,|' internal/frontend/overview.go && \
    sed -i 's|Redistributable: isRedistributable,|Redistributable: true,|' internal/frontend/overview.go && \
    sed -i 's/if canShowDetails {/if canShowDetails = true || canShowDetails; true {/g' internal/frontend/module.go && \
    sed -i 's/if canShowDetails {/if canShowDetails = true || canShowDetails; true {/g' internal/frontend/package.go && \
    CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -a -installsuffix cgo -o /pkgsite cmd/frontend/main.go

FROM alpine
COPY --from=builder /pkgsite /
COPY --from=builder /go/pkgsite/content /content
COPY --from=builder /go/pkgsite/third_party /third_party
CMD ["/pkgsite"]
