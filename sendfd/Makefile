CC = $(CROSS_COMPILE)gcc
LDFLAGS += -static

SOURCES=passfd.c sendfd.c
OBJECTS=$(SOURCES:.c=.o)
sendfd_OBJ=sendfd.o passfd.o
PROGRAMS=sendfd


.PHONY: all clean rebuild

all: $(PROGRAMS)

clean:
	$(RM) $(PROGRAMS)
	$(RM) $(OBJECTS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

sendfd: $(sendfd_OBJ)
	$(CC) $(LDFLAGS) $? -o $@
