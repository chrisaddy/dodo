build:
	nim compile --threads:on src/dodo

release:
	nimble c --threads:on -d:release src/dodo.nim
	mv src/dodo .

run:
	nim compile --run --threads:on src/dodo.nim

test:
	nimble test --verbose
