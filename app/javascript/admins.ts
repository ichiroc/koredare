// 管理画面用のTypeScript

export function copyToClipboard(elementId: string): void {
  const input = document.getElementById(elementId) as HTMLInputElement;
  if (!input) return;

  input.select();
  input.setSelectionRange(0, 99999); // For mobile devices

  navigator.clipboard.writeText(input.value).then(
    () => {
      // Success feedback
      const button = (event as any).currentTarget as HTMLButtonElement;
      const originalHTML = button.innerHTML;
      button.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-success" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>';

      setTimeout(() => {
        button.innerHTML = originalHTML;
      }, 2000);
    },
    (err) => {
      console.error('Failed to copy: ', err);
    }
  );
}

// グローバルに公開
(window as any).copyToClipboard = copyToClipboard;
