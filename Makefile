CFLAGS ?= -O2 -Wall -Wextra
LDFLAGS += -s
BIN = AppRun-patched-x86_64
LIB = exec-x86_64.so
EXEC_TEST = exec_test
ENV_TEST = env_test

checkrt: $(BIN) $(LIB)

test: $(EXEC_TEST) $(ENV_TEST)

all: checkrt test

clean:
	-rm -f $(BIN) $(LIB) $(EXEC_TEST) $(ENV_TEST) *.o AppRun.c AppRun-patched-x86_64.c

$(BIN): AppRun-patched-x86_64.o checkrt.o env.o

$(LIB): exec.o env.o
	$(CC) -shared $(LDFLAGS) -o $@ $^ -ldl

AppRun-patched-x86_64.o checkrt.o: CFLAGS += -include checkrt.h
exec.o env.o: CFLAGS += -fPIC

$(EXEC_TEST): CFLAGS += -DEXEC_TEST
$(EXEC_TEST): exec.c env.c
	$(CC) -o $@ $(CFLAGS) $^ -ldl

$(ENV_TEST): CFLAGS += -DENV_TEST
$(ENV_TEST): env.c
	$(CC) -o $@ $(CFLAGS) $^

run_tests: $(EXEC_TEST) $(ENV_TEST)
	./$(ENV_TEST)
	./$(EXEC_TEST)

AppRun-patched-x86_64.c: AppRun.c
	patch -p1 --output $@  < AppRun.c.patch

AppRun.c:
	wget -c "https://raw.githubusercontent.com/AppImage/AppImageKit/master/src/AppRun.c"

.PHONY: checkrt test run_tests all clean
