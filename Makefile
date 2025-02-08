SERVICES_PATHS = $(wildcard src/*/*.service)
SERVICES = $(notdir $(SERVICES_PATHS))
ESERVER_SERVICES = $(SERVICES:%=eserver-%)
INSTALLED_SERVICES = $(addprefix install/,$(ESERVER_SERVICES))

list:
	@echo $(ESERVER_SERVICES)

install/eserver-%.service: $(filter %.service,$(SERVICES_PATHS))
	cp -f "src/$*/$*.service" "$@"

install: $(INSTALLED_SERVICES)

link-eserver-%.service: disable-%.service install/eserver-%.service
	@[[ "$$UID" == 0 ]] || ( echo User must be root to link services!; exit 1)
	systemctl link "install/eserver-$*.service"

disable-%:
	@[[ "$$UID" == 0 ]] || ( echo User must be root to link services!; exit 1)
	-systemctl disable "$*" 2>&1 > /dev/null || true
	-systemctl show "$*" -p FragmentPath | sed 's/FragmentPath=//g' | xargs rm -rf

#link: $(addprefix disable-,$(ESERVER_SERVICES)) $(addprefix link-,$(ESERVER_SERVICES))

start-%: link-%
	@[[ "$$UID" == 0 ]] || ( echo User must be root to start services!; exit 1 )
	systemctl start "$*"

start-all: $(addprefix start-,$(ESERVER_SERVICES))

enable-%: link-%
	@[[ "$$UID" == 0 ]] || ( echo User must be root to start services!; exit 1 )
	systemctl enable "$*"

enable-all: $(addprefix enable-,$(ESERVER_SERVICES))

.PHONY: link install start-all

