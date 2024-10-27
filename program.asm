.686
.model flat

extern _ExitProcess@4 : PROC
extern __read : proc
extern __write : proc
public _main

.data
	
	special_signs db ';', ',', ':'
	special_signs_len dd 3d

	input_buffer db 80 dup (0)

	output_buffer db 80 dup(0)

.code

	_check_if_special proc
		push ebp
		mov ebp, esp
		push ecx
		push ebx
		push edi
		push esi

		;[ebp + 8] holds tester letter
		mov eax, [ebp + 8]
		mov ecx, special_signs_len ; ecx holds length
		xor esi, esi

		main_loop:
			cmp ecx, 0
			je not_found

			cmp al, special_signs[esi]
			je found

			dec ecx
			inc esi
			jmp main_loop

		found:
			mov eax, 1 ; 1 found
			jmp finish

		not_found:
			mov eax, 0
			jmp finish ; 0 not found

		finish:
			pop esi
			pop edi
			pop ebx
			pop ecx
			pop ebp
			ret
	_check_if_special endp


	_transform proc
		push ebp
		mov ebp, esp
		sub esp, 8 ; local var holding count, and output offset
		push ecx
		push ebx
		push edi
		push esi

		;[ebp + 4] ret
		;[ebp + 8] input_buffer
		;[ebp + 12] output_buffer
		;[ebp + 16] input len
		mov [ebp - 4], dword PTR 0 ; set count to 0
		mov [ebp - 8], dword PTR 0 ; set output offset to 0

		mov ecx, [ebp + 16] ; input len
		xor ebx, ebx ; holds tested letter
		xor esi, esi ; input counter
		xor edi, edi ; word letter counter

		main_loop:
			mov edx, [ebp + 8] ; input buffer
			cmp ecx, 0
			je finish

			mov bl, [edx + esi]
			cmp bl, 20h ; check if ' '
			je space_found

			push ebx ; push tested letter
			call _check_if_special
			add esp, 4

			cmp eax, 1 ; found
			je special

			cmp eax, 0
			je normal

		space_found:
			cmp edi, 4
			jae inc_count

			back_space:
				xor edi, edi ; reset word counter
				inc esi ; progress input counter
				dec ecx
			jmp main_loop

		special:
			mov eax, [ebp - 8] ; output offset
			mov edx, [ebp + 12] ; output offset 0
			mov [edx + eax], bl
			inc eax
			mov [ebp - 8], eax; increment output offset
			inc esi ; progress input counter
			dec ecx
			jmp main_loop

		normal:
			mov eax, [ebp - 8] ; output offset
			mov edx, [ebp + 12] ; output offset 0
			mov [edx + eax], bl
			inc eax
			mov [ebp - 8], eax; increment output offset
			inc edi ; increment letter counter
			inc esi ; progress input counter
			dec ecx
			jmp main_loop

		inc_count:
			add [ebp - 4], dword PTR 1
			jmp back_space

		inc_count_last_item:
			add [ebp - 4], dword PTR 1
			jmp finish_finish

		finish:
			cmp edi, 4
			jae inc_count_last_item

			finish_finish:
				mov eax, [ebp - 8] ; output offset
				mov edx, [ebp + 12] ; output offset 0
				mov ebx, [ebp - 4]
				add ebx, 30h ; add '0'
				mov [edx + eax], ebx
				pop esi
				pop edi
				pop ebx
				pop ecx
				add esp, 8
				pop ebp
				ret
	_transform endp


	_main proc
		push 80
		push OFFSET input_buffer
		push 0
		call __read
		add esp, 12

		dec eax ; dont count newline
		push eax
		push OFFSET output_buffer
		push OFFSET input_buffer
		call _transform
		add esp, 12
		
		push 80
		push OFFSET output_buffer
		push 1
		call __write
		add esp, 12

		push 0
		call _ExitProcess@4

	_main endp
END