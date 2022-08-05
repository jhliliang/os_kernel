#include <ntddk.h>


extern "C" {
	PDRIVER_OBJECT g_DriverObject;
}

IMAGE_LOAD_FLAGS

VOID NTAPI DriverUnload(PDRIVER_OBJECT DriverObject) {

	UNREFERENCED_PARAMETER(DriverObject);
	
	KdPrint(("DriverUnload"));
}


extern "C" NTSTATUS NTAPI DriverEntry(PDRIVER_OBJECT DriverObject,PUNICODE_STRING RegistryPath) {

	UNREFERENCED_PARAMETER(DriverObject);
	UNREFERENCED_PARAMETER(RegistryPath);

	g_DriverObject = DriverObject;
	KdPrint(("DriverEntry"));

	// set image loading notification routine

	NTSTATUS status = PsSetLoadImageNotifyRoutine();

	if (NT_SUCCESS(status))
	{
		
	}
	else
	{
		KdPrint(("DriverEntry"));
	}
	

	DriverObject->DriverUnload = DriverUnload;
	return 0;

}