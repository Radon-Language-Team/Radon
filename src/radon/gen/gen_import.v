module gen

import structs

const core_import_string = '#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

void println_str(char *x, ...) 
{ 
	va_list args;
	va_start(args, x);
	vprintf(x, args);
	printf("\\n");
	va_end(args);
}
void println_int(int x)
{
  printf("%d\\n", x);
}
void println_bool(int x)
{
	printf("%s\\n", x ? "true" : "false");
} 

char *read(char *message) 
{
  char temp[1024];
  printf("%s ", message);
  if (fgets(temp, sizeof(temp), stdin) == NULL) 
  {
    char *empty = malloc(1);
    if (empty) empty[0] = \'\\0\';
    return empty;
  }

  temp[strcspn(temp, "\\n")] = \'\\0\';

  char *result = malloc(strlen(temp) + 1);
  if (!result) return NULL;

  strcpy(result, temp);
  return result;
}

char *clone(char *original) {
  if (original == NULL) return NULL;

  size_t len = strlen(original);
  char *copy = malloc(len + 1);
  if (!copy) return NULL;

	strcpy(copy, original);
  return copy;
}
'

fn gen_import(node structs.ImportStmt) string {
	if node.path.contains('.rad') {
		return gen_custom_import(node)
	} else {
		return gen_radon_import(node)
	}
}

fn gen_radon_import(node structs.ImportStmt) string {
	if node.path == 'core' {
		return core_import_string
	} else {
		return ''
	}
}

fn gen_custom_import(node structs.ImportStmt) string {
	println('[NOT YET GENERATED] Custom import -> ${node.path}')
	return ''
}
