Void = Nothing # 1.0 ripped Void for whatever reason

# https://stackoverflow.com/questions/51994365/convert-refcwstring-to-string/51998210
function Base.unsafe_string(w::Cwstring)
	ptr = convert(Ptr{Cwchar_t}, w)
	ptr == C_NULL && throw(ArgumentError("cannot convert NULL to string"))
	buf = Cwchar_t[]
	i = 1
	while true
		c = unsafe_load(ptr, i)
		if c == 0
			break
		end
		push!(buf, c)
		i += 1
	end
	return String(transcode(UInt8, buf))
end

Base.pointer(ref::Ref) = Base.unsafe_convert(Ptr{eltype(ref)}, ref)
# deref is pretty much ref.x, but converting to Ptr{} here aswell
deref(ref::Ref) = Ptr{Int64}( ref.x )

const cc = "C:\\Julia\\bin\\ChakraCore.dll"

#const ch = "C:\\repos\\ChakraCore\\Build\\VcBuild\\bin\\x64_release\\ch.dll"
#start_ch() = ccall( (:start_ch, ch), Void, ())
#start_ch()

const JsErrorCode = Int32
const JsRuntimeAttributeNone = Int32(0)


runtime = Ref(0)
context = Ref(0)
result = Ref(0)
jsref = Ref(0)

ccall( (:JsCreateRuntime, cc), JsErrorCode, (Int32, Ptr{Int64}, Ptr{Int64}), 0, C_NULL, runtime)
print("got runtime=$runtime\n")

ccall( (:JsCreateContext, cc), JsErrorCode, (Ptr{Int64}, Ptr{Int64}), deref(runtime), context)
print("got context $context\n")

errorCode = ccall( (:JsSetCurrentContext, cc), JsErrorCode, (Ptr{Int64},), deref(context))
print("errorCode = $errorCode\n")

# JsRunScript(
#     _In_z_ const wchar_t *script,
#     _In_ JsSourceContext sourceContext,
#     _In_z_ const wchar_t *sourceUrl,
#     _Out_ JsValueRef *result);
errorCode = ccall( (:JsRunScript, cc), JsErrorCode, (Cwstring, Ptr{Int64}, Cwstring, Ptr{Int64}), "(()=>{return \'→asd\';})()", deref(context), "", result)
print("errorCode = $errorCode\n")

resultJSString = Ref(0)
errorCode = ccall( (:JsConvertValueToString, cc), JsErrorCode, (Ptr{Int64}, Ptr{Int64}), deref(result), resultJSString)
print("errorCode = $errorCode\n")
print("resultJSString = $resultJSString\n")

#const wchar_t *resultWC;
#size_t stringLength;
#JsStringToPointer(resultJSString, &resultWC, &stringLength);
#resultWC = Ref{Cwstring}()
resultWC = Ref{Cwstring}()
stringLength = Ref{Csize_t}(0)
errorCode = ccall( (:JsStringToPointer, cc), JsErrorCode, (Ptr{Int64}, Ptr{Int64}, Ptr{Csize_t}), deref(resultJSString), pointer(resultWC), stringLength)
resultString = Base.unsafe_string(resultWC.x)
print("resultWC = $resultWC\n")
print("stringLength = $stringLength\n")
print("resultString = $resultString\n")

#=
jsref = Ptr{Int64}(0)
JsCreateObject() = ccall( (:JsCreateObject, cc), Int32, (Ptr{Int64},), jsref)
IfJsrtErrorSetGo(ChakraRTInterface::JsCreateContext(runtime, &newContext));
ccall( (:JsGetCurrentContext, cc), Void, (Ptr{Int64},), jsref)
# IfJsErrorFailLog(ChakraRTInterface::JsCreateRuntime(jsrtAttributes, nullptr, runtime));
#  65539 = JsErrorNoCurrentContext
#  65538 = JsErrorNullArgument
# 196610 = JsErrorScriptCompile
=#