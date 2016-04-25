README.md: README.mdw
	julia -e "using Weave; weave(\"README.mdw\",doctype=\"github\",informat=\"markdown\")"
